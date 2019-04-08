# Tizen.NET Portal
Tizen .NET Portal is published at https://samsung.github.io/Tizen.NET/.


This project hosts the [Tizen .NET Portal](https://samsung.github.io/Tizen.NET/
) which provides the useful information about developing the Tizen .NET application in one space.<br/>
Visit the `Quick Guides` and the `Known Issues` to get started. See the `Posts` for the deeper information.

## Local Build Test
### Jekyll Environment
- Check out on [Jekyll Installation](https://jekyllrb.com/docs/installation/), or see the summary below.
  - Requirement
    - Ruby version 2.2.5 or above (`ruby -v`)
    - RubyGems (`gem -v`)
    - GCC and Make (`gcc -v`, `g++ -v`, `make -v`,)
  - Jekyll on Ubuntu
    - Install dependencies
      ```sh
      ~/ $ sudo apt-get install ruby-full build-essential zlib1g-dev
      ```
    - Install Jekyll
      ```sh
      ~/ $ gem install jekyll bundler
      ```
### Local Build
- Build and Generate on local
```sh
    ~/Tizen.NET $ bundle install
    ~/Tizen.NET $ bundle exec jekyll serve
```
- Check out the generated Page at `http://127.0.0.1:4000/Tizen.NET/`
