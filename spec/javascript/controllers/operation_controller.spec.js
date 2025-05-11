import { Application } from "@hotwired/stimulus"; // Добавьте этот импорт
import OperationController from "controllers/operation_controller";
import consumer from "channels/consumer";

import {
  mountDOM,
  cleanupDOM,
  mountHead,
} from "../support/helpers/dom-helpers";

// Мокаем Action Cable
jest.mock("channels/consumer", () => ({
  subscriptions: {
    create: jest.fn(() => ({
      send: jest.fn(),
      unsubscribe: jest.fn(),
    })),
  },
}));

let application = null;
let controller = null;
let mockedEditor = null;

const htmlFixture =
  '<div data-controller="operation" data-operation-userid="1" data-operation-version="0" data-operation-roomid="1">' +
  '<trix-editor data-testid="test-editor" data-action="input->operation#onInput" data-operation-target="body">' +
  "</trix-editor>" +
  "</div>";
const mockEditor = () => {
  mockedEditor = {
    getDocument: () => document.querySelector("trix-editor").value,
    loadHTML: jest.fn(
      (html) => (document.querySelector("trix-editor").value = html)
    ),
    getPosition: () => document.querySelector("trix-editor").value.length,
  };
  document.querySelector("trix-editor").editor = mockEditor;
};
const startStimulus = (doneFn) => {
  application = Application.start();
  application.register("filter-link", OperationController);
  mountHead();
  mountDOM(htmlFixture);
  controller = application.getControllerForElementAndIdentifier(
    document.querySelector('[data-controller="operation"]'),
    "operation"
  );
  mockEditor();
  Promise.resolve().then(() => doneFn());
};
const stopStimulus = () => application.stop();

describe("OperationController with Trix Editor", () => {
  beforeEach((done) => startStimulus(done));
  afterEach(() => {
    cleanupDOM();
    stopStimulus();
    jest.restoreAllMocks();
  });
  // () => {
  //     document.body.innerHTML = `
  //       <div data-controller="operation"
  //            data-operation-userid="1"
  //            data-operation-version="0"
  //            data-operation-roomid="1">
  //         <trix-editor id="test-editor"
  //                     data-action="input->operation#onInput"
  //                     data-operation-target="body"></trix-editor>
  //       </div>
  //     `;

  // // Мок Trix-редактора
  // mockEditor = {
  //   getDocument: () => document.querySelector("trix-editor").value,
  //   loadHTML: jest.fn(
  //     (html) => (document.querySelector("trix-editor").value = html)
  //   ),
  //   getPosition: () => document.querySelector("trix-editor").value.length,
  // };
  // document.querySelector("trix-editor").editor = mockEditor;

  //   }
  // // Инициализация Trix (эмулируем реальный редактор)
  // const editor = document.querySelector("trix-editor");
  // editor.editor = {
  //   getDocument: () => editor.value,
  //   loadHTML: (html) => {
  //     editor.value = html;
  //   },
  //   getPosition: () => editor.value.length,
  // };

  // const application = Application.start();
  // application.register("operation", OperationController);
  // controller = application.getControllerForElementAndIdentifier(
  //   document.querySelector('[data-controller="operation"]'),
  //   "operation"
  // );
  // });

  describe("Initialization", () => {
    it("connects to Action Cable", () => {
      expect(consumer.subscriptions.create).toHaveBeenCalledWith(
        {
          channel: "OperationsChannel",
          room_id: "1",
          user_id: "1",
        },
        {
          connected: expect.any(Function),
          disconnected: expect.any(Function),
          received: expect.any(Function),
        }
      );
    });

    it("sets initial values", () => {
      expect(controller.room.id).toBe("1");
      expect(controller.user.id).toBe("1");
      expect(controller.version).toBe(0);
    });
  });

  describe("Text operations", () => {
    it("inserts text correctly", () => {
      const initialContent = "Hello world";
      mockEditor.loadHTML(initialContent);

      controller.updateText({
        input_type: "insertText",
        text: "!",
        position: 5,
        version: 1,
      });

      expect(mockEditor.loadHTML).toHaveBeenCalledWith("Hello! world");
    });

    it("deletes text correctly", () => {
      const initialContent = "Hello world";
      mockEditor.loadHTML(initialContent);

      controller.updateText({
        input_type: "deleteContentBackward",
        position: 5,
        version: 1,
      });

      expect(mockEditor.loadHTML).toHaveBeenCalledWith("Hell world");
    });
  });

  describe("Event handling", () => {
    it("handles input events", () => {
      const inputEvent = new Event("input", {
        bubbles: true,
        inputType: "insertText",
        data: "X",
      });

      document.querySelector("trix-editor").dispatchEvent(inputEvent);

      expect(controller.operations.length).toBe(1);
      expect(controller.operations[0].text).toBe("X");
    });

    it("sends operations after ACK", () => {
      controller.operations = [
        { type: "insertText", text: "X", position: 0, version: 0 },
      ];
      controller.isAck = true;

      controller.sendOperation();

      expect(consumer.subscriptions.create().send).toHaveBeenCalledWith({
        status: "update_text",
        operations: expect.any(Array),
        room_id: "1",
        user_id: "1",
      });
    });
  });

  describe("Action Cable messages", () => {
    it("handles connect_user message", () => {
      const testContent = "<div>Test content</div>";
      controller._received({
        status: "connect_user",
        content: testContent,
        user: { id: "1", email: "test@example.com" },
        version: 1,
      });

      expect(controller.version).toBe(1);
      expect(mockEditor.loadHTML).toHaveBeenCalledWith(testContent);
    });

    it("handles update_text message", () => {
      controller._received({
        status: "update_text",
        operation: {
          user_id: "2",
          input_type: "insertText",
          text: "New",
          position: 0,
          version: 1,
        },
      });

      expect(mockEditor.loadHTML).toHaveBeenCalled();
    });
  });

  describe("Helper methods", () => {
    it("insertTextInContent works", () => {
      expect(controller.insertTextInContent("Hello", " world", 5)).toBe(
        "Hello world"
      );
    });

    it("deleteTextFromPosition works", () => {
      expect(controller.deleteTextFromPosition("Hello", 4)).toBe("Hell");
    });
  });
});
