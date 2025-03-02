import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

// Connects to data-controller="operation"
export default class extends Controller {
  static targets = ["body"];

  version = -1;
  connect() {
    console.log(
      "Will create a subscrition for channel 'OperationsChannel', room_id: %s",
      this.data.get("roomid")
    );
    this.subscription = consumer.subscriptions.create(
      {
        channel: "OperationsChannel",
        id: this.data.get("roomid"),
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
    this.subscription.send({
      status: "connect_user",
      content: this.bodyTarget.value,
      user: this.data.get("user"),
    });
    // Called when the subscription is ready for use on the server
  }

  _disconnected() {
    console.log("OperationsChannel disconnected");
    // Called when the subscription has been terminated by the server
  }

  _received(data) {
    // Called when there's incoming data on the websocket for this channel
    if (data.status === "update_text" && data.user != this.data.get("user")) {
      console.log(
        `OperationsChannel resived: ${data.content} from ${data.user}`
      );
      this.updateText(data);
    }
    if (data.status === "connect_user") {
      this.version = data.version;
      this.updateText(data);
      console.log(`${data.user} connect to room ${this.data.get("roomid")}`);
    }
  }

  updateText(data) {
    // Обновляем текст в редакторе
    if (this.bodyTarget.editor.getPosition()) {
      var position = this.bodyTarget.editor.getPosition();
      this.bodyTarget.editor.setPosition(position);
    }
    if (data.conetnt != "" || data.conetnt != "null") {
      console.log(`UpdateText`);
      this.bodyTarget.innerHTML = data.content;
    }
  }

  sendUpdate(event) {
    console.log(`sendUpdate ${event.data}`);
    // Отправляем изменения на сервер
    console.log(
      `send_content: ${
        event.data
      } position:${this.bodyTarget.editor.getPosition()}`
    );
    this.subscription.send({
      status: "update_text",
      operation: {
        type: event.inputType,
        text: event.data,
        position: this.bodyTarget.editor.getPosition(),
        version: this.data.get("version"),
      },
      user: this.data.get("user"),
    });
  }
}
