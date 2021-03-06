require './job.rb'

describe Job do
  class TestJob
    def perform
      'result'
    end
  end

  class TestJobMultipleParams
    def perform(_first_param, _second_param)
      'result'
    end
  end

  let(:class_name) { 'some_class_name' }
  let(:params) { ['some_param'] }
  subject(:job) { described_class.new(class_name, params) }

  describe '.initialize' do
    it 'assigns an id' do
      expect(subject.id).to be
    end

    it 'assigns the class name' do
      expect(subject.class_name).to eq('some_class_name')
    end

    it 'assigns the params' do
      expect(subject.params).to eq(params)
    end
  end

  describe '#enqueue' do
    it 'delegates enqueing to queue adapter' do
      expect(QueueAdapter).to receive(:enqueue).with(subject)

      subject.enqueue
    end
  end

  describe '#perform' do
    context 'when the class does not exist' do
      let(:class_name) { 'Invalid' }
      let(:params) { nil }

      context 'with some params' do
       let(:params) { ['invalid'] }

        it 'returns nil' do
          expect(subject.perform).to be_nil
        end

        it 'assigns an error' do
          subject.perform

          expect(subject.error).to_not be_nil
        end
      end
    end

    context 'when the class exists' do
      context 'when the method in the class does not expect params' do
        let(:class_name) { 'TestJob' }

        context 'with no params' do
          let(:params) { nil }

          it 'returns the evaluation of the method on the class' do
            expect_any_instance_of(TestJob).to receive(:perform).and_return('test')

            expect(subject.perform).to eq('test')
          end

          it 'does not assign an error' do
            subject.perform

            expect(subject.error).to be_nil
          end
        end

        context 'with some params' do
          let(:params) { ['invalid'] }

          it 'returns nil' do
            expect(subject.perform).to be_nil
          end

          it 'assigns an error' do
            subject.perform

            expect(subject.error).to_not be_nil
          end
        end
      end

      context 'when the method in the class expects params' do
        let(:class_name) { 'TestJobMultipleParams' }

        context 'with valid params' do
          let(:params) { ['leti', 'esperon'] }

          it 'returns the evaluation of the method on the class' do
            expect_any_instance_of(TestJobMultipleParams).to receive(:perform)
              .with('leti', 'esperon').and_return('test')

            expect(subject.perform).to eq('test')
          end

          it 'does not assign an error' do
            subject.perform

            expect(subject.error).to be_nil
          end
        end

        context 'with no params' do
          let(:params) { nil }

          it 'returns nil' do
            expect(subject.perform).to be_nil
          end

          it 'assigns an error' do
            subject.perform

            expect(subject.error).to_not be_nil
          end
        end
      end
    end
  end
end
