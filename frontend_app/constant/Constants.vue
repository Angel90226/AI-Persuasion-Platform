<script>
// Constants.vue
export default {
  MAX_TEMP: 1.2,
  MIN_TEMP: 0.4,
  DEFAULTS_TEMP: 0.6,
  POST_SURVEY_URL: 'https://moonbear.herokuapp.com/onlinesurvey/1c605f2b-27e5-4e5e-b60d-596ecf56cd0c/13b7a354-22ec-4566-a6a2-ccb689c5fd98',
  URL_USER_PARAMS: 'PROLIFIC_PID',
  URL_CONDITION_PARAMS: 'c',
  TIME_GAP:10,
  MISSION_TIME: 600,
  MISSION_EXPIRE_TIME: 3600,

  CONDITION_BASE64: {
    high_high: "ewogICAgInBvd2VyX2NvbmRpdGlvbiI6ICJoaWdoIiwKICAgICJwcmVzZW5jZV9jb25kaXRpb24iOiAiaGlnaCIKfQ==",
    high_low: "ewogICAgInBvd2VyX2NvbmRpdGlvbiI6ICJoaWdoIiwKICAgICJwcmVzZW5jZV9jb25kaXRpb24iOiAibG93Igp9",
    low_high: "ewogICAgInBvd2VyX2NvbmRpdGlvbiI6ICJsb3ciLAogICAgInByZXNlbmNlX2NvbmRpdGlvbiI6ICJoaWdoIgp9",
    low_low: "ewogICAgInBvd2VyX2NvbmRpdGlvbiI6ICJsb3ciLAogICAgInByZXNlbmNlX2NvbmRpdGlvbiI6ICJsb3ciCn0="
  },

  // NaviBot Constants
  NAVIBOT_INTRO: 
    `Hi! I'm your AI assistant.
    You are overseeing to reply to the HR department regarding their printer purchase request. Would you like me to start drafting the email?`,

  HIGH_POWER_ROLE_DESCRIPTION: 
    `You are the <span style="color: #ff6600; font-weight: bold;">Senior Procurement Manager</span> in your company's procurement department. <br>
    In this role, you <strong>oversee</strong> strategic purchasing decisions, <strong>manage</strong> supplier relationships, and <strong>ensure</strong> that procurement activities align with the company's goals and budget. You are <strong>responsible</strong> for reviewing product options, <strong>negotiating</strong> contracts, and <strong>coordinating</strong> with other departments to meet organizational needs. <br><br>
    You are currently working at a company that uses an internal AI assistant named AssistantBot to help employees complete their daily tasks more efficiently. <br><br>
    <strong>Please give the agent instructions and feedback to ensure that tasks reflect your intent before being completed.</strong>`,

  LOW_POWER_ROLE_DESCRIPTION: 
    `You are a <span style="color: #ff6600; font-weight: bold;">newly hired Procurement Assistant</span> in your company's procurement department.<br>
    In this role, you <strong>support</strong> daily procurement tasks such as <strong>preparing</strong> documentation, <strong>researching</strong> product options, <strong>contacting</strong> vendors, and <strong>organizing</strong> meeting notes. You are expected to <strong>follow</strong> standard procedures and carry out tasks as directed by your supervisors to ensure smooth and efficient procurement operations. <br><br>    
    You are currently working at a company that uses an internal AI supervisor named SupervisorBot to ensure employees complete their daily tasks more efficiently. <br><br>
    <strong>Please follow the agent's instructions carefully and complete the tasks as guided.</strong>`,

  NAVIBOT_EMAIL_REQUIREMENT: 
    `Dear Procurement Team, <br><br>
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
    'Either Agree or Disagree',
    'Somewhat Agree',
    'Agree',
    'Strongly Agree'
  ],

  PRINTERS: [
    {
      id: 'canon',
      name: 'Canon PIXMA TR7820',
      brand: 'Canon',
      image: 'canon.jpg',
      price: 129.00,
      specs: [
        'All-in-One: Print, Copy, Scan',
        'Print Speed: 15 ppm (black), 10 ppm (color)',
        '2.7" LCD Touchscreen',
        'Auto-Duplex, Auto Document Feeder',
        'Wireless & USB',
        '100-sheet paper capacity',
        'Color: White'
      ],
      fullSpecs: [
        'Model: PIXMA TR7820',
        'Dimensions: 15.9 x 14.2 x 8.2 inches',
        'Weight: 16 lbs',
        'Max Print Size: 8.5" x 11"',
        'Print Resolution: Up to 4800 x 1200 dpi',
        'Connectivity: USB, Wireless',
        'Paper Capacity: 100 sheets (cassette), 100 sheets (rear tray)',
        'ADF: 35 sheets',
        'Display: 2.7" LCD Touchscreen',
        'Compatible OS: Windows, Mac, Mobile',
        'Warranty: 1 year'
      ],
      features: [
        'Easy setup and maintenance',
        'Hybrid ink system for sharp text and vivid photos',
        'Poster Artist Online for banners and signage',
        'Energy Star certified'
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
      price: 69.99,
      specs: [
        'All-in-One: Print, Copy, Scan, Fax',
        'Print Speed: 20 ppm (black), 10 ppm (color)',
        '2.7" Color Touchscreen',
        'Auto-Duplex, Auto Document Feeder',
        'Wireless, Ethernet, USB',
        '225-sheet input tray',
        'Color: Gray'
      ],
      fullSpecs: [
        'Model: OfficeJet Pro 8025e',
        'Dimensions: 18.1 x 20.1 x 9.2 inches',
        'Weight: 18 lbs',
        'Max Print Size: 8.5" x 14"',
        'Print Resolution: Up to 4800 x 1200 dpi',
        'Connectivity: USB, Wireless, Ethernet',
        'Paper Capacity: 225 sheets',
        'ADF: 35 sheets',
        'Display: 2.7" Color Touchscreen',
        'Compatible OS: Windows, Mac, Mobile',
        'Warranty: 1 year'
      ],
      features: [
        'Smart Tasks shortcuts for productivity',
        'Self-healing Wi-Fi',
        'HP+ Smart Printing System',
        'Energy Star certified'
      ],
      reviews: [
        { user: 'Carol', stars: 5, text: 'Fast printing and lots of features for the price.' },
        { user: 'David', stars: 4, text: 'Good value, but setup took a bit longer than expected.' }
      ]
    }
  ]  
}
</script>


