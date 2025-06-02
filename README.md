
# Приложение с централизованной системой совместного редактирования в режиме реального времени
## Настройка

1. Установите Ruby https://rubyinstaller.org/
2. Установите Visual Studio Code. Ссылка с гайдом: https://code.visualstudio.com/docs/languages/ruby

3. Установите Node and NPM https://nodejs.org/en/download/
4. Скопиируйте проект

5. Насттройте проект: 
  ```
    bundle install
    npm install
    rails db:create
    rails db:migrate
  ```
6. Запустите `rails s` в терминале чтобы запустить сервер

## Запуск тестов
  ```
  rails spec
  ```
