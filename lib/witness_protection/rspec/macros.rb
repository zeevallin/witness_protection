module WitnessProtection
  module RSpec
    module Macros

      def it_has_been_witness_protected(field, *args, &blk)

        it { should respond_to("encrypt_#{field}") }

        context "ClassMethods" do

          it { expect(described_class).to respond_to("identify_by_#{field}") }
          let(:expected_token) { "super-seCret_url-token" }

          before(:each) do
            allow(subject).to receive(:__generate_secure_token__).with(field).and_return(expected_token)
            subject.send("encrypt_#{field}")
            subject.save!
          end

          identify_by_method = "identify_by_#{field}"
          describe ".#{identify_by_method}" do

            it "returns the record for the corresponding secure token" do
              expect( described_class.send(identify_by_method, expected_token) ).to eq subject
            end

            context "no records match the secure token" do

              it "should return nil" do
                described_class.send(identify_by_method, "bad token").should be_nil
              end

            end

          end

          identify_by_bang_method = "identify_by_#{field}!"
          describe ".#{identify_by_bang_method}" do

            it "returns the record for the corresponding secure token" do
              expect( described_class.send(identify_by_bang_method, expected_token) ).to eq subject
            end

            context "no records match the secure token" do

              it "raise active record error" do
                expect { described_class.send(identify_by_bang_method, "bad token") }.to raise_error ActiveRecord::RecordNotFound
              end

            end

          end

        end

        encrypt_token_method = "encrypt_#{field}"
        describe "##{encrypt_token_method}" do

          let(:expected_token) { "super-seCret_url-token" }

          before(:each) { allow(subject).to receive(:__generate_secure_token__).and_return(expected_token) }

          it "assigns a valid BCrypt hash to password reset token field" do
            expected_value = BCrypt::Engine.hash_secret(expected_token, Figaro.env.encryption_salt!)
            expect(subject).to receive("#{field}=").with(expected_value)
            subject.send(encrypt_token_method)
          end

          it "returns the token key" do
            expect( subject.send(encrypt_token_method) ).to eq expected_token
          end

        end

      end

    end
  end
end