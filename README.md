# Battleship Game

Welcome to the Battleship Game – a Sinatra-based web application that lets you play Battleship against an AI opponent.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [How to Play](#how-to-play)
- [Installation](#installation)
- [Dependencies](#dependencies)
- [License](#license)

## Overview

This Battleship Game is a web-based implementation of the classic game Battleship. The game includes a player grid and an AI grid, and the objective is to sink all the opponent's ships before they sink yours.

The project is implemented using Ruby with the Sinatra framework and features a modular structure with different components for the game logic, AI opponent, and graphical user interface.

## Features

- **Web-based Gameplay**: Play Battleship directly from your web browser.
- **AI Opponent**: Face off against an intelligent AI opponent that strategically plans its shots.
- **Modular Design**: The project is organized into separate modules for game logic, AI, and the user interface.
- **Random Ship Generator**: Ships are randomly generated, providing a unique game experience.

## How to Play

1. **Setup**: The game initializes with both the player and AI grids, each containing randomly placed ships.
2. **Gameplay**: Players take turns shooting at positions on the opponent's grid. The AI opponent responds with its strategic shots.
3. **Winning**: The game continues until one player sinks all the opponent's ships. The player or AI with the remaining ships wins.

## Installation

1. Clone the repository:
```Bash
   
   git clone https://github.com/yourusername/battleship-game.git
```

### Web Version (Sinatra)

2. Install and Configure Nginx:
 ```Bash
  sudo apt-get install nginx
```
3. Edit Nginx configuration (e.g., /etc/nginx/sites-available/battleship-game):
```
  server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:8080; # Unicorn address
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```
4. Create a symbolic link to sites-enabled:
 ```Bash
   sudo ln -s /etc/nginx/sites-available/battleship-game /etc/nginx/sites-enabled
```
5. Restart nginx
 ```Bash
   sudo service nginx restart
  ``` 
### Desktop Version (Tkinter) 


6. install tk gem and dependencies

```bash
   sudo apt install tk-dev
```

```bash
   gem install tk -- --with-tcltkversion=8.6 \
   --with-tcl-lib=/usr/lib/x86_64-linux-gnu \
   --with-tk-lib=/usr/lib/x86_64-linux-gnu \
   --with-tcl-include=/usr/include/tcl8.6 \
   --with-tk-include=/usr/include/tcl8.6 \
   --enable-pthread
   ```

7. Run the Game.rb
```Bash
   ruby game.rb
```

# Dependencies

## Web Version (Sinatra)

- [Ruby](https://www.ruby-lang.org/en/): The programming language used for the web application.
- [Sinatra](http://sinatrarb.com/): A web application framework for Ruby.
- [Unicorn](https://unicorn.bogomips.org/): A HTTP server for Ruby applications.
- [Nginx](https://nginx.org/): A web server used as a reverse proxy.

## Desktop Version (Tkinter)

- [Ruby](https://www.ruby-lang.org/en/): The programming language used for the desktop application.
- [Tk](https://docs.ruby-lang.org/en/2.7.0/Tk.html): The Ruby interface to the Tk GUI toolkit.


# License

This project is licensed under the [MIT License](LICENSE).


# Contact

For inquiries or further information, please contact alex.xirou@hotmail.com
