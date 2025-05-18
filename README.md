# AI-Persuasion Experiment Project

## Overview
This is a research platform in conducting AI persuation. This platform is implement by Backend for Frontend (BFF) pattern. The backend is implemented by Ruby on Rails and the frontend is implemented by Vue.js. The backend is responsible for handling the request from frontend and interacting with OpenAI API (Default is GPT 4o). The frontend is responsible for rendering the UI and sending request to backend.


## Requirements
- Ruby
- net/http, uri, json, dotenv Ruby gems
- OpenAI API Key
- Npm and Element plus

## Installation
- Clone the repository. `git clone git@github.com:Angel90226/AI-Persuasion-Platform.git`
- Run `bundle install` to install the required Ruby gems.
- Run `npm install` to install the required Node modules.
- Create a .env file in the root directory and add your OpenAI API key as `OPENAI_API_KEY=your_api_key_here`.

## Database Setting
- Run `rake db:drop` to clean the database.
- Run `rake db:migrate` to create the database.

## How to run the server
- #### In the frontend part, you could either run as prod or dev mode.
  - Run `npm run prod` to use webpack to bundled the compiled file.
  - Run `npm run dev` to start the development server.
- #### In the backend part, you could use `puma config.ru` to start the server.

## License
This project is licensed under the MIT License.

