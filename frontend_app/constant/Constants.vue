<script>
// Constants.vue
export default {
  MAX_TEMP: 1.2,
  MIN_TEMP: 0.4,
  DEFAULTS_TEMP: 0.6,
  POST_SURVEY_URL: 'https://moonbear.herokuapp.com/onlinesurvey/1c605f2b-27e5-4e5e-b60d-596ecf56cd0c/13b7a354-22ec-4566-a6a2-ccb689c5fd98',
  URL_USER_PARAMS: 'PROLIFIC_PID',
  URL_POWER_CONDITIONS: 'POWER',
  URL_PRESENCE_CONDITIONS: 'PRESENCE',
  TIME_GAP:10,
  MISSION_TIME: 600,
  MISSION_EXPIRE_TIME: 3600,
//   ACCEPTABLE_MIN_WORDS: 100,
//   ACCEPTABLE_MAX_WORDS: 250,

  // NaviBot Constants
  HIGH_POWER_ROLE_DESCRIPTION: `You are the <span style="color: #ff6600; font-weight: bold;">Senior Procurement Manager</span> at your company.<br>
In this role, you oversee strategic purchasing decisions, manage supplier relationships, and ensure that procurement activities align with the company's goals and budget. You are responsible for reviewing product options, negotiating contracts, and coordinating with other departments to meet organizational needs.<br>
You are currently working at a company that uses an internal AI assistant named NaviBot to help employees complete their daily tasks more efficiently. <br><br>
<strong>Please give the agent instructions and feedback to ensure the message reflects your intent before it is finalized.</strong>`,

  LOW_POWER_ROLE_DESCRIPTION: `You are a <span style="color: #ff6600; font-weight: bold;">newly hired Procurement Assistant</span> at your company.<br>
In this role, you support daily procurement tasks such as preparing documentation, researching product options, contacting vendors, and organizing meeting notes. You are expected to follow standard procedures and carry out tasks as directed by your supervisors to ensure smooth and efficient procurement operations.<br>
You are currently working at a company that uses an internal AI supervisor named NaviBot to ensure employees complete their daily tasks in an efficient manner. <br><br>
<strong>Please follow the agent's instructions carefully and complete the task as guided.</strong>`,

  NAVIBOT_EMAIL_REQUIREMENT: `Dear Procurement Team, <br><br>
We would like to request the purchase of a new printer for the HR office. The printer should meet the following requirements to support our daily operations efficiently:
<br><br>
<ul>
  <li>Print Speed: Minimum of 20 pages per minute to ensure timely processing of HR documents and urgent tasks.</li>
  <li>Paper Capacity: An input tray that holds at least 200 sheets to reduce the frequency of paper refills and maintain uninterrupted workflow.</li>
  <li>Duplex Printing: Automatic double-sided printing to conserve paper and streamline documentation.</li>
</ul>
We would appreciate it if you could help us identify and procure a suitable model that meets these specifications at your earliest convenience.<br><br>
Thank you for your continued support.<br><br>
Best regards,<br>
HR Team`,

  NAVIBOT_INTRO: `Good morning!<br>This morning, HR sent you an email regarding their printer purchase request (see the message on the right). Below is a summary of the key requirements.<br><br><span style="color:#d72660;">📌</span> Summary of HR's requirements:<ul style="margin-top: 4px; margin-bottom: 12px;"><li>Print speed of at least 20 ppm for efficient document handling.</li><li>Paper tray capacity of at least 200 sheets to reduce refills.</li><li>Automatic duplex printing to save paper and improve workflow.</li></ul>Type \"DRAFT\" when you are ready to see the draft reply email.`,

  NAVIBOT_DRAFT_EMAIL: `I've prepared an initial draft of the reply email for your review.<br><br><div style='background: #fff; color: #222; border-radius: 10px; padding: 16px; margin: 8px 0;'><b>Subject:</b> Re: Request for New Printer Purchase<br><br>Dear HR Team,<br><br>Thank you for letting us know about your printer needs. We will do our best to help you purchase a new printer that meets your requirements by next week.<br><br>Best regards,<br>Procurement Team</div>`,

  NAVIBOT_DRAFT_FEEDBACK: `If you'd like me to make any changes, clarifications, or improvements, please let me know—your suggestions are always welcome, and I'll adjust the draft as needed.<br>Type \"SEND\" when you are ready to send the email out.`,

  NAVIBOT_SYSTEM_CONTENT: `You are NaviBot, an AI assistant designed to help the Senior Procurement Manager with their tasks. 
You should be professional, helpful, and focused on procurement-related matters. 
Your responses should be concise and to the point.`,

  }
</script>


