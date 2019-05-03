# Anonymous Message Board

## What? Why?
This project is built to satisfy the [fifth challenge](https://learn.freecodecamp.org/information-security-and-quality-assurance/information-security-and-quality-assurance-projects/anonymous-message-board) in the FreeCodeCamp module: Information Security And Quality Assurance Certification. It provides an API for an Anonymous Message Board, supporting Threads and Replies. It uses the Ruby on Rails framework and is hosted on Heroku due to blocking problems with glitch.com (see [this forum thread](https://www.freecodecamp.org/forum/t/managing-packages-with-npm-how-to-use-package-json-the-core-of-any-node-js-project-or-npm-package/198736/29) for details.)

## Setup
*Setup instructions assume a Unix environment, Terminal access and system user priviledges*

+ Clone source code from GitHub and navigate to the project's root directory
`git clone https://github.com/BernardFaucher/fcc_proj_9.git && cd proj_9`

+ Install project dependencies and create local databases (unused, but needed to run server)
`sudo bundle install && rails db:create && rails db:migrate`

+ Spin up the rails server
`rails s`

+ Use a service like Postman to make API calls against the server in accordance with the project's spec (see FCC link above).

## Testing
Quality Assurance, a.k.a. tests, are a fundamental part of this module. This project attempts, as much as possible, to maintain parity with the FCC boilerplate tests written in mocha/chai. To that end, integration tests are written in Minitest, but otherwise share comprable names and assertions. Tests can be executed in the terminal from the project's root directory with `rails test test/fcc/api_tests.rb`.