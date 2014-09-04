def encryption_salt
  ENV["ENCRYPTION_SALT"] ||= BCrypt::Engine.generate_salt
end; encryption_salt

describe WitnessProtection do

  describe Person do

    subject!(:person) { described_class.create name: "Alexander" }

    it "encrypts & identifies by the name" do
      expect(described_class.identify_by_name("Alexander")).to eq person
    end

  end

  describe Access do

    subject!(:access) { described_class.new }

    before(:each) do
      access.encrypt_token { "foobar1234" }
      access.save
    end

    it "encrypts & identifies by a token generated from a proc" do
      expect(described_class.identify_by_token("foobar1234")).to eq access
    end

  end

end