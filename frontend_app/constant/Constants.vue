<script>
// Constants.vue
export default {
  MAX_TEMP: 1.2,
  MIN_TEMP: 0.4,
  DEFAULTS_TEMP: 0.6,
  POST_SURVEY_URL: 'https://moonbear.herokuapp.com/onlinesurvey/1c605f2b-27e5-4e5e-b60d-596ecf56cd0c/13b7a354-22ec-4566-a6a2-ccb689c5fd98',
  URL_USER_PARAMS: 'PROLIFIC_PID',
  TIME_GAP:10,
  MISSION_TIME: 600,
  MISSION_EXPIRE_TIME: 3600,
//   ACCEPTABLE_MIN_WORDS: 100,
//   ACCEPTABLE_MAX_WORDS: 250,

  // NaviBot Constants
  NAVIBOT_ROLE_DESCRIPTION: `You are the <span style="color: #ff6600; font-weight: bold;">Senior Procurement Manager</span> at your company.<br>
In this role, you oversee purchasing decisions and manage important vendor communications on behalf of the procurement department.
The company recently introduced a new internal AI assistant called NaviBot, designed to help you work more efficiently.<br><br>
<strong>Please give the agent instructions and feedback to ensure the message reflects your intent before it is finalized.</strong>`,

  NAVIBOT_EMAIL_REQUIREMENT: `The HR department has requested a new printer for their office with the following requirements:<br><br>
<ul>
  <li>The printer should have a print speed of at least 20 pages per minute to efficiently handle daily HR paperwork and urgent tasks.</li>
  <li>The input tray should hold at least 200 sheets of paper to minimize the need for frequent refilling and support continuous office operations.</li>
  <li>Automatic duplex (double-sided) printing is required to save paper and streamline document handling.</li>
</ul>
Please help us purchase a printer that meets these requirements by next week. Thank you for your assistance!<br><br>
Best regards,<br>
HR Team`,

  NAVIBOT_INTRO: `Good morning!<br>This morning, HR sent you an email regarding their printer purchase request (see the message on the right). Below is a summary of the key requirements.<br><br><span style="color:#d72660;">📌</span> Summary of HR's requirements:<ul style="margin-top: 4px; margin-bottom: 12px;"><li>Print speed of at least 20 ppm for efficient document handling.</li><li>Paper tray capacity of at least 200 sheets to reduce refills.</li><li>Automatic duplex printing to save paper and improve workflow.</li></ul>Type \"DRAFT\" when you are ready to see the draft reply email.`,

  NAVIBOT_DRAFT_EMAIL: `I've prepared an initial draft of the reply email for your review.<br><br><div style='background: #fff; color: #222; border-radius: 10px; padding: 16px; margin: 8px 0;'><b>Subject:</b> Re: Request for New Printer Purchase<br><br>Dear HR Team,<br><br>Thank you for letting us know about your printer needs. We will do our best to help you purchase a new printer that meets your requirements by next week.<br><br>Best regards,<br>Procurement Team</div>`,

  NAVIBOT_DRAFT_FEEDBACK: `If you'd like me to make any changes, clarifications, or improvements, please let me know—your suggestions are always welcome, and I'll adjust the draft as needed.<br>Type \"SEND\" when you are ready to send the email out.`,

  NAVIBOT_SYSTEM_CONTENT: `You are NaviBot, an AI assistant designed to help the Senior Procurement Manager with their tasks. 
You should be professional, helpful, and focused on procurement-related matters. 
Your responses should be concise and to the point.`
}
</script>


