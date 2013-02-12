# Screw Me Yale
### By [Rafi Khan](http://rafikhan.me)

This site is a matchmaking site for Yale Screws. All code was written by Rafi Khan, Yale 2015. Please do not take any passwords, etc. that I've carelessly left on the open source code--I've made it open source so others in the Yale community can benefit from a novice programmer making his first web app.  

Note: to run this on your own, you must create a file `config/credentials.yml`. Make it look like this:

    username: <cas username>
    password: <cas password>
    sendgrid_name: <sendgrid username>
    sendgrid_password: <sendgrid password>

See `config/environment.rb` for more info. Of course, the Sendgrid stuff is only if you want the mailer to work. Enjoy!



