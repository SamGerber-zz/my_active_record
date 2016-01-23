require 'manifest'

describe 'Validatable' do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Cat < SQLObject
      validates :name, presence: true

      finalize!
    end

    class Human < SQLObject
      self.table_name = 'humans'

      validates :owner_id, presence: true, uniqueness: true

      finalize!
    end

    class House < SQLObject

      finalize!
    end
  end

  describe '::valid_options' do
    it 'defaults to empty hash' do
      class TempClass < SQLObject
      end

      expect(TempClass.validatable_options).to eq({})
    end

    it 'stores `validates` options' do
      cat_valid_options = Cat.validatable_options

      expect(cat_valid_options).to be_instance_of(ValidatesOptions)
      expect(cat_valid_options.column).to eq(:name)
      expect(cat_valid_options.validations).to eq(presence: true)
    end

    it 'stores options separately for each class' do
      expect(Cat.validatable_options.column).to eq(:name)
      expect(Human.validatable_options.column).to_not eq(:name)

      expect(Human.validatable_options.column).to eq(:owner_id)
      expect(Cat.validatable_options.column).to_not eq(:owner_id)
    end
  end


  context 'when a record is retrieved from db' do

    # before(:all) do
    #   class Cat < SQLObject
    #     validates :name, presence: true, uniqueness: true
    #
    #     finalize!
    #   end
    # end
    let(:cat) { Cat.find(1) }

    describe '#valid?' do
      it 'is valid' do
        expect(cat.valid?).to be true
      end

      it 'is not invalid' do
        expect(cat.invalid?).to be false
      end
    end

    describe '#errors' do
      it 'is empty prior to validations being run' do
        expect(cat.errors).to be_empty
      end

      it 'is still empty after validations are run' do
        cat.valid?
        expect(cat.errors).to be_empty
      end
    end

    describe '#save' do
      it 'returns true' do
        expect(cat.save).to eq(true)
      end

      it "doesn't change the database" do
        expect { cat.save }.to_not change {Cat.all.count}
      end
    end

    describe '#save!' do
      it 'returns true' do
        expect(cat.save!).to eq(true)
      end

      it 'does not raise an error' do
        expect { cat.save! }.to_not raise_error
      end

      it "doesn't change the database" do
        expect { cat.save! }.to_not change {Cat.all.count}
      end
    end
  end

  context 'when retrieved record is edited to fail presence' do
    let(:cat) { Cat.find(1) }
    before(:each) do
      cat.name = ''
    end

    describe '#valid?' do
      it 'is not valid' do
        expect(cat.valid?).to be false
      end

      it 'is invalid' do
        expect(cat.invalid?).to be true
      end
    end

    describe '#errors' do
      it 'is empty prior to validations being run' do
        expect(cat.errors).to be_empty
      end

      it 'is no longer empty after validations are run' do
        cat.valid?
        expect(cat.errors).to_not be_empty
      end

      it "has a 'name nust not be blank' error" do
        cat.valid?
        expect(cat.errors[:name]).to include("must not be blank")
      end
    end

    describe '#save' do
      it 'returns false' do
        expect(cat.save).to eq(false)
      end

      it "doesn't change the database" do
        expect { cat.save }.to_not change {Cat.all.count}
      end
    end

    describe '#save!' do
      it 'raises a helpful error' do
        expect do
          cat.save!
        end.to raise_error(RecordInvalid, "name: must not be blank")
      end
      it "doesn't change the database" do
        expect do
          begin
            cat.save
          rescue RecordInvalid
          end
        end.to_not change { Cat.all.count }
      end
    end
  end

  context 'when a new invalid object is instantiated' do
    let(:cat) { Cat.new }

    describe '#valid?' do
      it 'is not valid' do
        expect(cat.valid?).to be false
      end

      it 'is invalid' do
        expect(cat.invalid?).to be true
      end
    end

    describe '#errors' do
      it 'is empty prior to validations being run' do
        expect(cat.errors).to be_empty
      end

      it 'is no longer empty after validations are run' do
        cat.valid?
        expect(cat.errors).to_not be_empty
      end

      it "has a 'name nust not be blank' error" do
        cat.valid?
        expect(cat.errors[:name]).to include("must not be blank")
      end
    end

    describe '#save' do
      it 'returns false' do
        expect(cat.save).to eq(false)
      end

      it "doesn't change the database" do
        expect { cat.save }.to_not change {Cat.all.count}
      end
    end

    describe '#save!' do

      it 'raises a helpful error' do
        expect do
          cat.save!
        end.to raise_error(RecordInvalid, "name: must not be blank")
      end

      it "doesn't change the database" do
        expect do
          begin
            cat.save
          rescue RecordInvalid
          end
        end.to_not change { Cat.all.count }
      end
    end
  end

  context 'when a new valid object is instantiated' do
    let(:cat) { Cat.new(name: "Chewie") }

    describe '#valid?' do
      it 'is valid' do
        expect(cat.valid?).to be true
      end

      it 'is not invalid' do
        expect(cat.invalid?).to be false
      end
    end

    describe '#errors' do
      it 'is empty prior to validations being run' do
        expect(cat.errors).to be_empty
      end

      it 'is still empty after validations are run' do
        cat.valid?
        expect(cat.errors).to be_empty
      end
    end

    describe '#save' do
      it 'returns true' do
        expect(cat.save).to eq(true)
      end

      it "updates the database" do
        expect { cat.save }.to change { Cat.all.count }
      end
    end

    describe '#save!' do
      it 'returns true' do
        expect(cat.save).to eq(true)
      end

      it "updates the database" do
        expect { cat.save }.to change { Cat.all.count }
      end
    end
  end
end
