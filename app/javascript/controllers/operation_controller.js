import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

// Connects to data-controller="operation"
export default class extends Controller {
  static targets = ["body"];

  connect() {
    console.log(
      "Will create a subscrition for channel 'OperationsChannel', room_id: %s",
      this.data.get("roomid")
    );
    this.isAck = true;
    this.version = 0;
    this.operations = [];
    this.room = { id: this.data.get("roomid") };
    this.user = { id: this.data.get("userid") };
    this.subscription = consumer.subscriptions.create(
      {
        channel: "OperationsChannel",
        room_id: this.room.id,
        user_id: this.user.id,
      },
      {
        connected: this._connected.bind(this),
        disconnected: this._disconnected.bind(this),
        received: this._received.bind(this),
      }
    );
    //data-action="trix-change->operation#sendUpdate"
    //this.bodyTarget.addEventListener("trix-change", this.sendUpdate.bind(this));
  }
  _connected() {
    console.log("OperationsChannel connected");
    this.subscription.send({ status: "connect_user" });

    // Called when the subscription is ready for use on the server
  }

  _disconnected() {
    console.log("OperationsChannel disconnected");
    // Called when the subscription has been terminated by the server
  }

  _received(data) {
    // Called when there's incoming data on the websocket for this channel
    if (data.status === "update_text") {
      console.log(
        `OperationsChannel resived operation:
         ${JSON.stringify(data.operation)}`
      );
      this.version = data.operation.version;
      if (data.operation.user_id == this.user.id) {
        console.log("acknowlage");
        this.isAck = true;
        this.sendOperation();
        console.log(`ACK version:${this.version}`);
      } else {
        this.updateText(data.operation);
      }
    }
    if (data.status === "connect_user") {
      console.log(`${data.user.email} connect to room ${this.room.id}`);
      if (data.user.id == this.user.id) {
        this.version = data.version;
        this.loadText(data.content);
      }
    }
  }

  loadText(content) {
    if (content) {
      // this.bodyTarget.innerHTML = content;
      this.bodyTarget.editor.loadHTML(content);
    }
  }

  // Обновляем текст в редакторе
  updateText(operation) {
    console.log(`UpdateText`);
    const document = this.bodyTarget.editor.getDocument();
    // Получаем текущее содержимое
    let currentContent = document.toString().slice(0, -1);
    let newContent = currentContent.replace(/\n/g, "");
    if (newContent.includes("\u00A0")) {
      console.log(`AAAAAAAAAATass"`);
    }
    console.log(`editor.getDocument: "${document}"`);
    console.log(`editor.getDocument.slice(0, -1): "${newContent}"`);
    console.log(`html: "${this.bodyTarget.value}"`);
    newContent = this.applyOperation(newContent, operation);
    this.loadNewConent(newContent);
    console.log(`newContent: "${newContent}"`);
    console.log(`html: "${this.bodyTarget.value}"`);
  }
  loadNewConent(newContent) {
    // this.bodyTarget.editor.loadHTML("");
    // this.bodyTarget.editor.insertHTML(newContent);
    this.bodyTarget.editor.loadHTML(`<p>${newContent}</p>`); //loadText
    // this.bodyTarget.editor.deleteInDirection("backward");
  }
  applyOperation(content, operation) {
    let newContent = content;
    if (operation.input_type == "insertText") {
      // Вставляем текст в указанную позицию
      newContent = this.insertTextInContent(
        content,
        operation.text,
        operation.position
      );
    } else if (
      operation.input_type == "deleteContentBackward" ||
      operation.input_type == "deleteContentForward" ||
      operation.input_type == "delete"
    ) {
      newContent = this.deleteTextFromPosition(content, operation.position);
    }
    return newContent;
  }
  // сleanNBSP() {
  //   // const doc = this.bodyTarget.editor.getDocument();
  //   // const doc = this.bodyTarget.value;
  //   // const is_nbsp = doc.toString().endsWith("\u00A0");
  //   // console.log(`check: |${doc.toString()}| - ${is_nbsp}`);
  //   // if (is_nbsp) {
  //   // this.bodyTarget.editor.deleteInDirection("backward");
  //   // }
  // }
  onInput(event) {
    var inputText = event.data;
    position = this.bodyTarget.editor.getPosition();
    if (event.inputType == "insertText") {
      var position = position - 1;
    }
    if (inputText == null) {
      inputText = "";
    }
    console.log(`operation = {
      type: ${event.inputType}
      text: "${inputText}"
      position:${position}
      version: ${this.version} }`);
    var operation = {
      type: event.inputType,
      text: inputText,
      position: position,
      version: this.version,
    };
    this.operations.unshift(operation);
    if (this.isAck) {
      this.sendOperation();
      this.isAck = false;
    }
  }
  sendOperation() {
    if (this.operations.length != 0) {
      var operation = this.operations.pop();
      var operation_for_send = {
        status: "update_text",
        operations: [operation],
        room_id: this.room.id,
        user_id: this.user.id,
      };
      this.subscription.send(operation_for_send);
    }
  }

  insertTextInContent(content, text, position) {
    let newContent =
      content.slice(0, position) + text + content.slice(position);
    return newContent;
  }

  deleteTextFromPosition(content, position) {
    let newContent = content.slice(0, position) + content.slice(position + 1);
    return newContent;
  }
}
