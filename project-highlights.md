# Food Manager & Food Manager Admin
[![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?logo=dart&logoColor=white)](#) [![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?logo=javascript&logoColor=000)](#) [![NodeJS](https://img.shields.io/badge/Node.js-6DA55F?logo=node.js&logoColor=white)](#)

[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=fff)](#) [![Google Cloud](https://img.shields.io/badge/Google%20Cloud-%234285F4.svg?logo=google-cloud&logoColor=white)](#) [![Firebase](https://img.shields.io/badge/Firebase-039BE5?logo=Firebase&logoColor=white)](#) [![Firebase Hosting](https://img.shields.io/badge/Firebase%20Hosting-039BE5?logo=Firebase&logoColor=white)](#)

**Timeline:** 2025  
**Platform:** Browser, Android, iOS (Admin tool: browser only)  
**Team/Solo:** Solo

**Repositories:** 
> [https://github.com/jbrun001/foodmanager](https://github.com/jbrun001/foodmanager)
> 
> [https://github.com/jbrun001/foodmanager_admin](https://github.com/jbrun001/foodmanager_admin)

---

## Description
A household food management application (meal planning, shopping lists) designed to help reduce food waste.

## Features
- Meal Planning, recipe scaling
- Smart shopping lists, automatically generated based on existing stock, meal plans and the minimum pack sizes from supermarkets  
- Left over ingredient preview - based the current shopping list, and the meals planned what ingredients will be left over, and what recipes could be cooked with those (so users can review and adjust meal plans to reduce the left overs)
- Recipe Database
- Food Waste Logging and Analysis
- Ingredient Pack Size web scraping

## Experiment
During this project, I ran an experiment. Will using this app reduce food waste? Trial participant households were asked to collect food waste data initially reporting via a google form and then during the trial of the app, reporting in the app. The app was developed as part of the method of this experiment.
Details of the experiment can be found here:

> https://github.com/jbrun001/foodmanager/experiment/Food_Waste_Analysis_Final.html

## Project
This was the first project that I had managed that had a full trial with participants using an app which could have an impact on their household finances (meal planning and food purchase). The trial created time pressure withing the project, but also helped with focus when deciding priorities (if the feature / function helped the success of the trial it was a higher priority).

Working across 4 platforms (web, Android, iOS, and Admin web) was a challenge in terms of testing. By selecting native flutter components only the Authentication elements required platform specific code.

For the admin interface in the project I re-used my APIProject as a template (https://github.com/jbrun001/APIProject). It's a secure node.js app (csrf, rate-limiting etc.) which had a material design, menus, and log in routes built. I updated this to use google sign in, and all the route functionality required for Food Manager. 

This worked well and I think I will combine the two projects as a template (offering My-SQL/bcrypt and google sign in ) which has routes in as examples, that can be used for any future projects.

## Deployment
- Firestore was used as the database for this application, this worked well.
- The web deployment of the Food Manager app was deployed to firebase hosting.
- The admin application was built into a docker container and deployed to google cloud run

## Web Scraping
Puppeteer Puppeteer-extra and Puppeteer-extra-stealth were used to scrape ingredient pack sizes. This project doesn't have high frequency requirements for scraping (pack sizes change infrequently, so infrequent scrapes are required). Scraping was deployed using headless Chromium in a docker image with the node admin app.

## Skills Developed
- **Flutter/Dart** - New language for me.
- **OAuth 2.0** - google sign in, firebase_auth
- **Cross Platform Development** - Android/iOS/Web
- **NoSQL** - Firebase Admin, Firebase.  
- **Docker** - Containerisation
- **Cloud Compute** - Google Cloud Run - pushing containers.
- **CRUD** - Stock control implementation
- **Scraping** - Puppeteer, button clicking, Chromium, batching and results/log management
- **People Management** - managing Trial Participants.
- **Mac Development** - better understanding of macOS and the apple ecosystem for development (Xcode etc.)

---
[Return to my portfolio](https://jbrun001.github.io/allprojects.html)

---