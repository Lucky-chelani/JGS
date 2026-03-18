const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const {defineSecret} = require('firebase-functions/params');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

const GEMINI_API_KEY = defineSecret('GEMINI_API_KEY');
const SMTP_USER = defineSecret('SMTP_USER');
const SMTP_PASS = defineSecret('SMTP_PASS');
const SMTP_HOST = defineSecret('SMTP_HOST');
const SMTP_PORT = defineSecret('SMTP_PORT');

const BRAND = {
  name: 'JGS Store',
  tagline: 'Beauty and Care',
  supportPhone: '+91 8770132554',
  supportEmail: 'support@jagdishgeneralstore.com',
  siteUrl: 'https://jgs-store.web.app',
  colors: {
    primary: '#B76E79',
    dark: '#8B4A52',
    bg: '#FDF8F5',
    surface: '#FFFFFF',
    text: '#2D1B20',
    subtle: '#5A3A40',
    border: '#E8D5D0',
  },
};

function cleanParts(parts) {
  return parts.filter((v) => typeof v === 'string' && v.trim() !== '');
}

function cleanEmail(value) {
  if (typeof value !== 'string') return '';
  const v = value.trim();
  return v.includes('@') ? v : '';
}

function htmlEscape(value) {
  return String(value || '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function formatMultiline(value) {
  return htmlEscape(value).replaceAll('\n', '<br/>');
}

function buildEmailShell({title, preheader, bodyHtml, ctaLabel, ctaUrl}) {
  const cta = ctaLabel && ctaUrl
    ? `<div style="margin-top:20px;"><a href="${htmlEscape(ctaUrl)}" style="display:inline-block;background:${BRAND.colors.primary};color:#ffffff;text-decoration:none;padding:12px 22px;border-radius:10px;font-weight:700;font-size:14px;">${htmlEscape(ctaLabel)}</a></div>`
    : '';

  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${htmlEscape(title)}</title>
  <style>
    body { margin:0; padding:0; background:${BRAND.colors.bg}; font-family:Arial, sans-serif; color:${BRAND.colors.text}; }
    .wrap { width:100%; padding:24px 10px; box-sizing:border-box; }
    .card { max-width:620px; margin:0 auto; background:${BRAND.colors.surface}; border:1px solid ${BRAND.colors.border}; border-radius:16px; overflow:hidden; }
    .head { background:linear-gradient(135deg, #FDF8F5 0%, #FCF3F0 100%); border-bottom:1px solid ${BRAND.colors.border}; padding:26px 24px; text-align:center; }
    .brand { color:${BRAND.colors.primary}; font-size:28px; font-weight:800; margin:0; }
    .tag { color:${BRAND.colors.subtle}; font-size:12px; letter-spacing:1.2px; text-transform:uppercase; margin:6px 0 0 0; }
    .content { padding:24px; }
    .title { margin:0 0 10px 0; font-size:24px; line-height:1.25; color:${BRAND.colors.text}; }
    .text { margin:0 0 12px 0; font-size:14px; line-height:1.65; color:${BRAND.colors.subtle}; }
    .panel { background:${BRAND.colors.bg}; border:1px solid ${BRAND.colors.border}; border-radius:12px; padding:14px; margin:14px 0; }
    .panel-title { margin:0 0 8px 0; color:${BRAND.colors.dark}; font-size:12px; text-transform:uppercase; letter-spacing:1px; font-weight:800; }
    .footer { padding:18px 24px 24px 24px; border-top:1px solid ${BRAND.colors.border}; background:${BRAND.colors.bg}; }
    .foot { margin:0; font-size:12px; line-height:1.6; color:${BRAND.colors.subtle}; }
    .prehead { display:none; visibility:hidden; opacity:0; color:transparent; height:0; width:0; overflow:hidden; }
  </style>
</head>
<body>
  <span class="prehead">${htmlEscape(preheader || title)}</span>
  <div class="wrap">
    <div class="card">
      <div class="head">
        <p class="brand">JGS</p>
        <p class="tag">${BRAND.tagline}</p>
      </div>
      <div class="content">
        ${bodyHtml}
        ${cta}
      </div>
      <div class="footer">
        <p class="foot"><strong>${BRAND.name}</strong></p>
        <p class="foot">Support: ${htmlEscape(BRAND.supportPhone)} | ${htmlEscape(BRAND.supportEmail)}</p>
        <p class="foot">${htmlEscape(BRAND.siteUrl)}</p>
      </div>
    </div>
  </div>
</body>
</html>`;
}

async function queueEmail({to, subject, html, userId}) {
  if (!Array.isArray(to) || to.length === 0 || !subject || !html) return;
  return admin.firestore().collection('mail').add({
    to,
    message: {subject, html},
    userId: userId || null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function getUserEmail(userId) {
  if (!userId) return '';
  const userSnap = await admin.firestore().collection('users').doc(userId).get();
  if (!userSnap.exists) return '';
  const raw = userSnap.data()?.email;
  return cleanEmail(raw);
}

function buildAdminEnquiryHtml({kind, data}) {
  const name = htmlEscape(data.userName || data.ownerName || data.name || 'Unknown');
  const phone = htmlEscape(data.phone || data.userPhone || 'N/A');
  const city = htmlEscape(data.city || 'N/A');
  const details = formatMultiline(data.requirements || data.makeupType || data.message || 'N/A');
  const meta = cleanParts([
    data.date ? `Date: ${htmlEscape(data.date)}` : '',
    data.time ? `Time: ${htmlEscape(data.time)}` : '',
    data.venue ? `Venue: ${htmlEscape(data.venue)}` : '',
    data.budget ? `Budget: ${htmlEscape(data.budget)}` : '',
    data.salonName ? `Salon: ${htmlEscape(data.salonName)}` : '',
  ]).join('<br/>');

  const bodyHtml = [
    `<h1 class="title">New ${htmlEscape(kind)} Enquiry</h1>`,
    '<p class="text">A new enquiry has been submitted and requires review.</p>',
    '<div class="panel">',
    '<p class="panel-title">Customer Details</p>',
    `<p class="text"><strong>Name:</strong> ${name}<br/><strong>Phone:</strong> ${phone}<br/><strong>City:</strong> ${city}</p>`,
    '</div>',
    meta ? `<div class="panel"><p class="panel-title">Enquiry Meta</p><p class="text">${meta}</p></div>` : '',
    `<div class="panel"><p class="panel-title">Request Details</p><p class="text">${details}</p></div>`,
    '<p class="text">Open the admin panel to take action on this enquiry.</p>',
  ].join('');

  return buildEmailShell({
    title: `New ${kind} Enquiry`,
    preheader: `New ${kind} enquiry received`,
    bodyHtml,
    ctaLabel: 'Open Admin Panel',
    ctaUrl: `${BRAND.siteUrl}/#/admin`,
  });
}

function buildUserAckHtml({kind, name}) {
  const safeName = htmlEscape(name || 'there');
  const bodyHtml = [
    `<h1 class="title">We received your ${htmlEscape(kind)} enquiry</h1>`,
    `<p class="text">Hi ${safeName},</p>`,
    '<p class="text">Thank you for reaching out to JGS. Our team will contact you shortly with the next steps.</p>',
    '<div class="panel">',
    '<p class="panel-title">What Happens Next</p>',
    '<p class="text">1) Our team reviews your request.<br/>2) We contact you via phone/email.<br/>3) We share personalized recommendations.</p>',
    '</div>',
    '<p class="text">Regards,<br/>JGS Team</p>',
  ].join('');

  return buildEmailShell({
    title: 'Enquiry Received - JGS',
    preheader: 'We have received your enquiry',
    bodyHtml,
    ctaLabel: 'Visit JGS Store',
    ctaUrl: BRAND.siteUrl,
  });
}

function buildAnnouncementHtml({title, message, target, type}) {
  const safeTitle = htmlEscape(title);
  const safeMessage = formatMultiline(message);
  const safeTarget = htmlEscape(target || 'All Customers');
  const safeType = htmlEscape(type || 'Promotional');

  const bodyHtml = [
    `<h1 class="title">${safeTitle}</h1>`,
    `<p class="text">Latest ${safeType.toLowerCase()} update from ${BRAND.name}.</p>`,
    '<div class="panel">',
    '<p class="panel-title">Announcement</p>',
    `<p class="text">${safeMessage}</p>`,
    '</div>',
    `<p class="text"><strong>Audience:</strong> ${safeTarget}</p>`,
  ].join('');

  return buildEmailShell({
    title: safeTitle,
    preheader: safeTitle,
    bodyHtml,
    ctaLabel: 'Shop Now',
    ctaUrl: BRAND.siteUrl,
  });
}

function sanitize(value) {
  return typeof value === 'string' ? value.trim() : '';
}

function templateDescription(name, category, concern) {
  const focus = concern ? ` Focused on ${concern.toLowerCase()},` : '';
  return `${name} is a thoughtfully formulated ${category.toLowerCase()} product for daily beauty care.${focus} it delivers effective results with a lightweight feel and skin-friendly usage. Suitable for Indian routines and weather, this product helps you maintain a polished look with consistent use.`;
}

exports.suggestProductDescription = onCall(
  {secrets: [GEMINI_API_KEY]},
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Login required.');
    }

    const uid = request.auth.uid;
    const adminDoc = await admin.firestore().collection('admins').doc(uid).get();
    if (!adminDoc.exists) {
      throw new HttpsError('permission-denied', 'Admin access required.');
    }

    const name = sanitize(request.data?.name);
    const category = sanitize(request.data?.category);
    const concern = sanitize(request.data?.concern);

    if (!name || !category) {
      throw new HttpsError('invalid-argument', 'name and category are required.');
    }

    const prompt = [
      'You are a beauty e-commerce copywriter.',
      'Write a concise Indian retail-friendly product description in 50-90 words.',
      'Use simple, trust-building language.',
      'Do not use markdown or bullet points.',
      `Product Name: ${name}`,
      `Category: ${category}`,
      concern ? `Concern: ${concern}` : 'Concern: General beauty care',
      'Return only the final description text.'
    ].join('\n');

    const apiKey = GEMINI_API_KEY.value();
    if (!apiKey || apiKey.startsWith('CHANGE_ME')) {
      return {
        description: templateDescription(name, category, concern),
        source: 'template-fallback',
      };
    }

    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;

    try {
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          contents: [{parts: [{text: prompt}]}],
          generationConfig: {
            temperature: 0.6,
            maxOutputTokens: 180
          }
        })
      });

      if (!response.ok) {
        const errText = await response.text();
        console.error('Gemini API error:', errText);
        return {
          description: templateDescription(name, category, concern),
          source: 'template-fallback',
        };
      }

      const data = await response.json();
      const text = data?.candidates?.[0]?.content?.parts?.[0]?.text?.trim() || '';

      if (!text) {
        return {
          description: templateDescription(name, category, concern),
          source: 'template-fallback',
        };
      }

      return {description: text, source: 'gemini'};
    } catch (err) {
      console.error('Gemini callable failed, fallback used:', err);
      return {
        description: templateDescription(name, category, concern),
        source: 'template-fallback',
      };
    }
  }
);
exports.sendBulkAlert = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Login required.');
    }

    const uid = request.auth.uid;
    const adminDoc = await admin.firestore().collection('admins').doc(uid).get();
    if (!adminDoc.exists) {
      throw new HttpsError('permission-denied', 'Admin access required.');
    }

    const title = sanitize(request.data?.title);
    const message = sanitize(request.data?.message);
    const target = sanitize(request.data?.sentTo) || 'All Customers';
    const type = sanitize(request.data?.type) || 'Promotional';

    if (!title || !message) {
      throw new HttpsError('invalid-argument', 'title and message are required.');
    }

    // Fetch all users
    const usersSnapshot = await admin.firestore().collection('users').get();
    const users = usersSnapshot.docs.map(doc => ({
      uid: doc.id,
      ...doc.data()
    }));

    console.log(`Sending bulk alert: "${title}" to ${users.length} users.`);

    const results = {
      total: users.length,
      smsSent: 0,
      emailSent: 0,
      failed: 0
    };

    // Serial processing for simplicity in this demo, 
    // though Promise.all would be faster for real APIs.
    for (const user of users) {
      try {
        const phone = user.phone;
        const email = user.email;

        // Log the "sending" action
        console.log(`[ALERT] Processing user ${user.name || 'User'}: SMS:${phone}, Email:${email}`);

        // Placeholder for real SMS API (e.g., Twilio / Fast2SMS)
        if (phone) {
          // await sendSMS(phone, message);
          results.smsSent++;
        }

        // Add to mail collection for the trigger to pick up
        if (email) {
          await admin.firestore().collection('mail').add({
            to: [email],
            message: {
              subject: title,
              html: buildAnnouncementHtml({
                title,
                message,
                target,
                type,
              }),
            },
            userId: user.uid,
          });
          results.emailSent++;
        }
      } catch (err) {
        console.error(`Failed to process alert for user ${user.uid}:`, err);
        results.failed++;
      }
    }

    // Log the alert in Firestore as well for history
    await admin.firestore().collection('alerts').add({
      title,
      message,
      sentTo: target,
      type,
      sentAt: new Date().toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' }),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      stats: results
    });

    return {
      success: true,
      summary: `Sent to ${results.smsSent} phones and ${results.emailSent} emails.`,
      results
    };
  }
);

/**
 * Triggered when a new document is added to the 'mail' collection.
 */
exports.processMailQueue = onDocumentCreated(
  {
    document: 'mail/{docId}',
    secrets: [SMTP_USER, SMTP_PASS, SMTP_HOST, SMTP_PORT]
  },
  async (event) => {
    const data = event.data.data();
    if (!data) return;

    const {to, message} = data;
    if (!to || !message) {
      console.error('Invalid mail document: missing "to" or "message"');
      return;
    }

    try {
      const smtpUser = SMTP_USER.value();
      const smtpPass = SMTP_PASS.value();
      const smtpHost = SMTP_HOST.value();
      const smtpPort = SMTP_PORT.value();

      if (
        !smtpUser || !smtpPass || !smtpHost || !smtpPort ||
        smtpUser.startsWith('CHANGE_ME') ||
        smtpPass.startsWith('CHANGE_ME') ||
        smtpHost.startsWith('CHANGE_ME') ||
        smtpPort.startsWith('CHANGE_ME')
      ) {
        return event.data.ref.update({
          delivery: {
            state: 'SKIPPED_CONFIG',
            reason: 'SMTP secrets not configured',
            skippedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
        });
      }

      const transporter = nodemailer.createTransport({
        host: smtpHost,
        port: parseInt(smtpPort),
        secure: parseInt(smtpPort) === 465,
        auth: {
          user: smtpUser,
          pass: smtpPass,
        },
      });

      const mailOptions = {
        from: `"JGS Store" <${smtpUser}>`,
        to: Array.isArray(to) ? to.join(', ') : to,
        subject: message.subject,
        html: message.html,
      };

      const info = await transporter.sendMail(mailOptions);
      console.log('Email sent successfully:', info.messageId);

      // Update document status
      return event.data.ref.update({
        delivery: {
          state: 'SUCCESS',
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          messageId: info.messageId,
        },
      });
    } catch (error) {
      console.error('Error sending email:', error);
      return event.data.ref.update({
        delivery: {
          state: 'ERROR',
          error: error.message,
          attempts: (data.delivery?.attempts || 0) + 1,
          lastErrorAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      });
    }
  }
);

exports.onBridalEnquiryCreated = onDocumentCreated(
  {
    document: 'bridal_enquiries/{enquiryId}',
    secrets: [SMTP_USER],
  },
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const adminEmail = cleanEmail(SMTP_USER.value());
    const userId = sanitize(data.userId);
    const userEmail = await getUserEmail(userId);

    const tasks = [];

    if (adminEmail) {
      tasks.push(queueEmail({
        to: [adminEmail],
        subject: 'New Bridal Enquiry Received',
        html: buildAdminEnquiryHtml({kind: 'Bridal', data}),
        userId,
      }));
    }

    if (userEmail) {
      tasks.push(queueEmail({
        to: [userEmail],
        subject: 'Your Bridal Enquiry Is Received',
        html: buildUserAckHtml({kind: 'bridal', name: data.userName}),
        userId,
      }));
    }

    await Promise.all(tasks);
  }
);

exports.onSalonOwnerEnquiryCreated = onDocumentCreated(
  {
    document: 'salon_owner_enquiries/{enquiryId}',
    secrets: [SMTP_USER],
  },
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const adminEmail = cleanEmail(SMTP_USER.value());
    const userId = sanitize(data.userId);
    const userEmail = await getUserEmail(userId);

    const tasks = [];

    if (adminEmail) {
      tasks.push(queueEmail({
        to: [adminEmail],
        subject: 'New Salon Partner Enquiry Received',
        html: buildAdminEnquiryHtml({kind: 'Salon Partner', data}),
        userId,
      }));
    }

    if (userEmail) {
      tasks.push(queueEmail({
        to: [userEmail],
        subject: 'Your Salon Partner Enquiry Is Received',
        html: buildUserAckHtml({kind: 'salon partner', name: data.userName || data.ownerName}),
        userId,
      }));
    }

    await Promise.all(tasks);
  }
);
