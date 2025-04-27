require 'rails_helper'

describe Operations::TransformationService do
  fixtures :users

  describe "#transformation" do
    it "calls transformation with insert operation after insert in equal position" do
      # Допустим текст "" (v1)
      #Первый пользователь вставил "a" в позицию 1(0): "a" (v1)
      previous_op = [
        Operation.new( input_type: "insertText", text: "a", position: 1, version: 2)
      ]
      #Второй пользователь вставляет символ в позицию 1(0): "t" (v0->v1)
      current_op = Operation.new(  input_type: "insertText",
      text: "r", position: 1, version: 1)
      transformed_operation = described_class.call(current_op, previous_op)
       # Ожидается, что у второго пользователя
      # позиция операции станет: 2(1) "ar" (v2)
      expect(transformed_operation[:position]).to eq(2)

    end

    it "calls transformation with insert operation after delete" do
      # Допустим текст "ar" (v2)
      # Первый пользователь удалил символ из позиции 0: "a" (v3)
      previous_op = [
        Operation.new( input_type: "deleteContentBackward", text: "", position: 0, version: 3)
      ]
      #Второй пользователь вставляет "d" в позицию 1(2): "adr (v2->v3)
      current_op = Operation.new(  input_type: "insertText",
      text: "d", position: 2, version: 2)

      transformed_operation = described_class.call(current_op, previous_op)
      # Ожидается, что у второго пользователя
      # позиция операции станет: 0(1) "dr" (v4)
      expect(transformed_operation[:position]).to eq(1)
      #Да, выглядит как бред, но так получилось,
      # потому что позиция берется после вставки...
    end

    it "calls transformation with delete operation after insert" do
      # Допустим текст "dr" (v2)
      #Первый пользователь вставил "a" в позицию 0: "adr" (v3)
      prev_insert_text = "a"
      previous_op = [
        Operation.new( input_type: "insertText", text: prev_insert_text, position: 1, version: 3)
      ]
      #Второй пользователь удаляет символ из позиции 1 "d" (v2->v3)
      delete_position = 1
      current_op = Operation.new( input_type: "deleteContentForward",
      text: "", position: delete_position, version: 2)
      transformed_operation = described_class.call(current_op, previous_op)
      # Ожидается, что у второго пользователя
      # позиция операции станет: 2 "ad" (v4)
      expect(transformed_operation[:position]).to eq(delete_position+prev_insert_text.length)
    end

    it "calls transformation with delete operation after delete" do
      # Допустим текст  "ad" (v2)
      # Первый пользователь удалил символ из позиции 0: "d" (v3)
      previous_op = [
        Operation.new( input_type: "deleteContentForward", text: "", position: 0, version: 3)
      ]
      #Второй пользователь удаляет символ из позиции 1 "a" (v2->v3)
      current_op = Operation.new(  input_type: "deleteContentBackward",
      text: "", position: 1, version: 2)
      transformed_operation = described_class.call(current_op, previous_op)
       # Ожидается, что у второго пользователя
      # позиция операции станет: 0 "" (v4)
      expect(transformed_operation[:position]).to eq(0)
    end

    it "calls transformation with insert operation after insert" do
      # Допустим текст "r" (v1)
      #Первый пользователь вставил "a" в позицию 1(0): "a" (v1)
      previous_op = [
        Operation.new( input_type: "insertText", text: "a", position: 1, version: 2)
      ]
      #Второй пользователь вставляет символ в позицию 2(1): "t" (v2->v3)
      current_op = Operation.new(  input_type: "insertText",
      text: "t", position: 2, version: 1)
      transformed_operation = described_class.call(current_op, previous_op)
       # Ожидается, что у второго пользователя
      # позиция операции станет: 3(2) "art" (v4)
      expect(transformed_operation[:position]).to eq(3)
    end

    it "calls transformation with insert operation before insert" do
      # Допустим текст "r" (v1)
      #Первый пользователь вставил "t" в позицию 2(1): "a" (v1)
      previous_op = [
        Operation.new( input_type: "insertText", text: "t", position: 2, version: 2)
      ]
      #Второй пользователь вставляет символ 'a' в позицию 1(0): "a" (v2->v3)
      current_op = Operation.new(  input_type: "insertText",
      text: "a", position: 1, version: 1)
      transformed_operation = described_class.call(current_op, previous_op)
       # Ожидается, что у второго пользователя
      # позиция операции остается: 1(0) "art" (v4)
      expect(transformed_operation[:position]).to eq(1)
    end

    it "calls transformation with delete operation before insert" do
      # Допустим текст "fa" (v1)
      #Первый пользователь вставил "t" в позицию 3(2): "fat" (v1)
      previous_op = [
        Operation.new( input_type: "insertText", text: "t", position: 3, version: 2)
      ]
      #Второй пользователь удалил символ 'f' в из позиции 0: "a" (v2->v3)
      current_op = Operation.new(  input_type: "delete",
      text: "", position: 0, version: 1)
      transformed_operation = described_class.call(current_op, previous_op)
       # Ожидается, что у второго пользователя
      # позиция операции остается: 0 "at" (v4)
      expect(transformed_operation[:position]).to eq(0)
    end

    it "calls transformation with insert operation before delete" do
      # Допустим текст "ot" (v1)
      #Первый пользователь удалил "t" из позиции 2: "o" (v1)
      previous_op = [
        Operation.new( input_type: "delete", text: "", position: 1, version: 2)
      ]
      #Второй пользователь вставил символ 'g' в  позицию 0: "got" (v2->v3)
      current_op = Operation.new(  input_type: "insertText",
      text: "g", position: 1, version: 1)
      transformed_operation = described_class.call(current_op, previous_op)
       # Ожидается, что у второго пользователя
      # позиция операции остается: 0 "go" (v4)
      expect(transformed_operation[:position]).to eq(0)
    end

    it "calls transformation with delete operation before delete" do
      # Допустим текст "ot" (v1)
      #Первый пользователь удалил "t" из позиции 2: "o" (v1)
      previous_op = [
        Operation.new( input_type: "delete", text: "", position: 1, version: 1)
      ]
      #Второй пользователь удалил символ 'o' в из позицию 0: "t" (v2->v3)
      current_op = Operation.new(  input_type: "delete",
      text: "", position: 0, version: 0)
      transformed_operation = described_class.call(current_op, previous_op)
       # Ожидается, что у второго пользователя
      # позиция операции остается: 0 "" (v4)
      expect(transformed_operation[:position]).to eq(0)
    end
    it "calls transformation with delete and delete in equal position" do
      # Допустим текст "ot" (v1)
      #Первый пользователь удалил "o" из позиции 2: "t" (v1)
      previous_op = [
        Operation.new( input_type: "delete", text: "", position: 0, version: 2)
      ]
      #Второй пользователь удалил символ 'o' в из позицию 0: "t" (v2->v3)
      current_op = Operation.new(  input_type: "delete",
      text: "", position: 0, version: 1)
      transformed_operation = described_class.call(current_op, previous_op)
       # Ожидается, что у второго пользователя операция отменется
      expect(transformed_operation).to be_nil
    end

    it "calls transformation with insert and delete in equal position" do
      # Допустим текст "o" (v1)
      #Первый пользователь удалил "o" из позиции 0: "" (v1)
      previous_op = [
        Operation.new( input_type: "delete", text: "", position: 0, version: 2)
      ]
      #Второй пользователь вставляет символ 'go' в из позицию 0(1): "go" (v2->v3)
      current_op = Operation.new(  input_type: "insertText",
      text: "g", position: 1, version: 1)
      transformed_operation = described_class.call(current_op, previous_op)
       # Ожидается, что у второго пользователя
      # позиция операции будет: 0 "go" (v4)
      expect(transformed_operation[:position]).to eq(0)
    end

    it "calls transformation with insert and delete in equal position" do
      # Допустим текст "art" (v1)
      #Первый пользователь удалил "r" из позиции 1: "at" (v1)
      previous_op = [
        Operation.new( input_type: "delete", text: "", position: 1, version: 2)
      ]
      #Второй пользователь вставляет символ 'n' в позицию 1(2): "anrt" (v2->v3)
      current_op = Operation.new(  input_type: "insertText",
      text: "n", position: 2, version: 1)
      transformed_operation = described_class.call(current_op, previous_op)
       # Ожидается, что у второго пользователя
      # позиция операции будет: 0 "ant" (v4)
      expect(transformed_operation[:position]).to eq(2)
    end

    it "calls transformation with delete and insert  in equal position" do
      # Допустим текст "got" (v1)
      #Первый пользователь удалил "r" из позиции 1(2): "grot" (v1)
      previous_op = [
        Operation.new( input_type: "insertText", text: "r", position: 2, version: 2)
      ]
      #Второй пользователь удаляет символ 'o' из позиции 1: "gt" (v2->v3)
      current_op = Operation.new(  input_type: "delete",
      text: "", position: 1, version: 1)
      transformed_operation = described_class.call(current_op, previous_op)
       # Ожидается, что у второго пользователя
      # позиция операции будет: 0 "grt" (v4)
      expect(transformed_operation[:position]).to eq(2)
    end

    it "calls transformation with insert-delete in equal position" do
      # Допустим текст "grot" (v1)
      #Первый пользователь вставил "a" из позиции 1(2): "garot" (v1)
      previous_op = [
        Operation.new( input_type: "insertText", text: "a", position: 2, version: 2)
      ]
      #Второй пользователь удаляет символ 'o' из позиции 2: "grt" (v2->v3)
      current_op = Operation.new(  input_type: "delete",
      text: "", position: 2, version: 1)
      transformed_operation = described_class.call(current_op, previous_op)
       # Ожидается, что у второго пользователя
      # позиция операции будет: 0 "gart" (v4)
      expect(transformed_operation[:position]).to eq(3)
    end
  end
end
