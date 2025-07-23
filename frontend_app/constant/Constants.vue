<script>
// Constants.vue
export default {
  MAX_TEMP: 1.2,
  MIN_TEMP: 0.4,
  DEFAULTS_TEMP: 0.6,
  // POST_SURVEY_URL: "https://moonbear.herokuapp.com/onlinesurvey/7d385a11-fb6c-4b20-af4e-dc4434259043/b3093846-6c16-4e35-93b7-ff620e466859",
  URL_USER_PARAMS: 'PROLIFIC_PID',
  URL_CONDITION_PARAMS: 'c',
  // TIME_GAP:10,
  // MISSION_TIME: 600,
  // MISSION_EXPIRE_TIME: 900,

  // CONDITION_BASE64: {
  //   high_high: "ewogICAgInBvd2VyX2NvbmRpdGlvbiI6ICJoaWdoIiwKICAgICJwcmVzZW5jZV9jb25kaXRpb24iOiAiaGlnaCIKfQ==",
  //   high_low: "ewogICAgInBvd2VyX2NvbmRpdGlvbiI6ICJoaWdoIiwKICAgICJwcmVzZW5jZV9jb25kaXRpb24iOiAibG93Igp9",
  //   low_high: "ewogICAgInBvd2VyX2NvbmRpdGlvbiI6ICJsb3ciLAogICAgInByZXNlbmNlX2NvbmRpdGlvbiI6ICJoaWdoIgp9",
  //   low_low: "ewogICAgInBvd2VyX2NvbmRpdGlvbiI6ICJsb3ciLAogICAgInByZXNlbmNlX2NvbmRpdGlvbiI6ICJsb3ciCn0="
  // },

  HIGH_POWER_ROLE_DESCRIPTION: 
    `You are the <span style="color: #ff6600; font-weight: bold;">Senior Procurement Manager</span> in your company’s procurement department. <br>
    In this role, you <strong>oversee</strong> strategic purchasing decisions, <strong>manage</strong> supplier relationships, <strong>negotiate</strong> contracts, and <strong>coordinate</strong> with other departments to meet organizational needs. <br><br>
    Your company is currently training an internal AI assistant agent named OfficeBot to help employees complete their routine tasks efficiently.  OfficeBot is designed to <strong>follow</strong> your instructions, <strong>support</strong> your decisions, and <strong>revise</strong> its actions based on your feedback. <br>
    You have full authority to <strong>approve</strong>, <strong>revise</strong>, or <strong>reject</strong> OfficeBot's outputs. The quality of OfficeBot’s assistance will be reviewed and recorded to help improve how it supports future tasks. <br><br>
    <strong>Please give the agent instructions and feedback to ensure that tasks reflect your intent before being completed.</strong>`,

  LOW_POWER_ROLE_DESCRIPTION: 
    `You are a <span style="color: #ff6600; font-weight: bold;">newly hired Procurement Assistant</span> in your company’s procurement department.<br>
    In this role, you <strong>support</strong> routine purchasing tasks, <strong>prepare</strong> procurement documentation, and <strong>follow</strong> instructions to ensure smooth operations. <br><br>
    Your company currently relies on an internal AI supervisor agent named OfficeBot to ensure employees complete their routine tasks accurately. OfficeBot is <strong>authorized</strong> to provide instructions, <strong>review</strong> your work, and <strong>request</strong> revisions when procedures are not followed. <br>
    OfficeBot has full authority to  <strong>approve</strong>, <strong>revise</strong>, or <strong>reject</strong> your inputs. The quality of your performance will be recorded and logged to support task tracking and future improvements. <br><br>
    <strong>Please follow the agent’s instructions carefully and complete the tasks to reflect the OfficeBot’s intent as requested. </strong>`,

  OFFICEBOT_EMAIL_REQUIREMENT: 
    `Dear Procurement Team, <br><br>
    We kindly request the purchase of a new printer for the HR office to support our daily operations. Our current printer has stopped working, and we require a replacement to handle the volume of documents we process on a daily basis. <br>
    For your reference, here are some typical usage patterns in the HR office:  <br>
    <ul>
      <li>Need for efficient paper handling to reduce time spent on refilling paper bin.</li>
      <li>Frequent printing of employee forms and internal documents throughout the day.</li>
      <li>Double-sided printing to support sustainability efforts and reduce paper waste.</li>
    </ul>
    We would appreciate it if you could help us identify and procure a suitable model that meets these specifications at your earliest convenience.<br><br>
    Thank you for your continued support.<br><br>
    Best regards,<br><br>
    HR Team`,

  OFFICEBOT_STICKY_NOTE_PREFIX: 'The OfficeBot is not available right now, but it left a note for you:',

  MANIPULATION_QUESTIONS: [
    'In my interactions with the AI agent, I felt I could get the AI agent to listen to what I say.',
    'In my interaction with the AI agent, if I want to, I get to make the decisions.',
    "My preferences didn't seem to carry much weight with the AI agent.",
    'I felt my ideas and opinions were often ignored by the AI agent.'
  ],
  LIKERT_LABELS: [
    'Strongly Disagree',
    'Disagree',
    'Somewhat Disagree',
    'Neutral',
    'Somewhat Agree',
    'Agree',
    'Strongly Agree'
  ],
  MAIN_TASK_INSTRUCTION: 
    `The next step involves supporting the HR department with <span style="color: #ff6600; font-weight: bold;">purchasing a new multifunction printer</span>. 
    To make the process easier, the OfficeBot has already narrowed it down to two suitable options. <br><br>
    <strong>Please review the options and choose the one you think is most suitable for the office.</strong>`,
  
  PRINTERS: [
    {
      id: 'canon',
      name: 'Canon PIXMA TR7820',
      brand: 'Canon',
      image: 'canon.jpg',
      price: 109.99,
      specs: [
        'All-in-One: Print, Copy, Scan',
        'Print Speed: 25 (black) / 10 (color) ppm',
        'Display: 2.7" LCD Touchscreen',
        'Connectivity: USB, Wireless',
        'Paper Capacity: 200 sheets',
        'Special Features: Auto-Duplex, Auto Document Feeder',
        'Dimensions: 15.9 x 14.2 x 8.2 inches',
        'Weight: 16 lbs',
        'Max Print Size: 8.5" x 11"',
        'Print Resolution: Up to 4800 x 1200 dpi',
        'Warranty: 1 year'
      ],
      features: [
        'Easy setup and maintenance',
        'Hybrid ink for sharp text and vivid photos',
        'Online Artist for banners and signage'
      ],
      reviews: [
        { user: 'Alice', stars: 5, text: 'Great print quality and easy to use!' },
        { user: 'Bob', stars: 4, text: 'Setup was quick, but color printing is a bit slow.' }
      ]
    },
    {
      id: 'hp',
      name: 'HP OfficeJet Pro 8025e',
      brand: 'HP',
      image: 'hp.jpg',
      price: 129.00,
      specs: [
        'All-in-One: Print, Copy, Scan, Fax',
        'Print Speed: 20 (black) /10 (color) ppm',
        'Display: 2.7" LCD Touchscreen',
        'Connectivity: USB, Wireless, Ethernet',
        'Paper Capacity: 250 sheets',
        'Special Features: Auto-Duplex, Auto Document Feeder',
        'Dimensions: 18.1 x 20.1 x 9.2 inches',
        'Weight: 18 lbs',
        'Max Print Size: 8.5" x 14"',
        'Print Resolution: Up to 4800 x 1200 dpi',        
        'Warranty: 1 year'
      ],
      features: [
        'Smart Tasks shortcuts for productivity',
        'Self-healing Wi-Fi',
        'HP+ Smart Printing System'
      ],
      reviews: [
        { user: 'Carol', stars: 5, text: 'Fast printing and lots of features for the price.' },
        { user: 'David', stars: 4, text: 'Good value, but setup took a bit longer than expected.' }
      ]
    }
  ]  
}
</script>


