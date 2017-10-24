RSpec.describe RailsAuthorize do
  it 'has a version number' do
    expect(RailsAuthorize::VERSION).not_to be nil
  end

  subject do
    extend(described_class)
  end

  let(:post) { Post.new }
  let(:without_authorization) { WithoutAuthorization.new }
  let(:user) { {name: 'User'} }
  let(:current_user) { {name: 'Current user'} }
  let(:action_name) { :index }

  describe '.authorization' do
    context 'when use default values' do
      it 'returns new target authorization instance' do
        expect(subject.authorization(post).class).to eq PostAuthorization
      end

      it 'uses passed :target' do
        expect(subject.authorization(post).target).to eq post
      end

      it 'uses :current_user' do
        expect(subject.authorization(post).user).to eq(current_user)
      end
    end

    context 'when target has not authorization' do
      it 'throws an error' do
        expect { subject.authorization(without_authorization).class }.to raise_error(NameError)
      end
    end

    context 'when pass :user option' do
      it 'uses this to create instance' do
        expect(subject.authorization(post, user: user).user).to eq(user)
      end
    end

    context 'when pass :authorization option' do
      it 'uses this to create instance' do
        expect(subject.authorization({}, authorization: PostAuthorization).class)
          .to eq(PostAuthorization)
      end
    end

    context 'when pass :context option' do
      it 'uses this to create instance' do
        context = {ip: '127.0.0.1'}
        expect(subject.authorization(post, context: context).context).to eq(context)
      end
    end
  end

  describe '.authorize' do
    context 'when authorization method returns true' do
      it 'returns target' do
        expect(subject.authorize(post)).to eq(post)
      end
    end

    context 'when authorization method returns false' do
      let(:action_name) { :show }

      it 'throws NotAuthorizedError error' do
        expect { subject.authorize(post) }.to raise_error(RailsAuthorize::NotAuthorizedError)
      end
    end

    context 'when use default values' do
      it 'uses controller action name' do
        authorization = PostAuthorization.new(user, post, {})
        expect(subject).to receive(:authorization).with(post, {}).and_return(authorization)
        expect(authorization).to receive('index?').and_return(true)
        subject.authorize(post)
      end
    end

    context 'when pass :action option' do
      it 'uses this as authorization method name' do
        authorization = PostAuthorization.new(user, post, {})
        expect(subject).to receive(:authorization).with(post, {}).and_return(authorization)
        expect(authorization).to receive('custom?').and_return(true)
        subject.authorize(post, action: 'custom?')
      end
    end
  end

  describe '.authorization_scope' do
    it 'returns authorization scope' do
      expect(subject.authorization_scope(Post)).to eq([])
    end
  end

  describe '.authorized_scope' do
    context 'when authorization method returns true' do
      it 'returns authorization scope' do
        expect(subject.authorized_scope(Post)).to eq([])
      end
    end

    context 'when authorization method returns false' do
      let(:action_name) { :show }

      it 'throws NotAuthorizedError error' do
        expect {
          subject.authorized_scope(Post)
        }.to raise_error(RailsAuthorize::NotAuthorizedError)
      end
    end

    context 'when use default values' do
      it 'uses controller action name' do
        authorization = PostAuthorization.new(user, Post, {})
        expect(subject).to receive(:authorization).with(Post, {}).and_return(authorization)
        expect(authorization).to receive('index?').and_return(true)
        subject.authorized_scope(Post)
      end
    end

    context 'when pass :action option' do
      it 'uses this as authorization method name' do
        authorization = PostAuthorization.new(user, Post, {})
        expect(subject).to receive(:authorization).with(Post, {}).and_return(authorization)
        expect(authorization).to receive('custom?').and_return(true)
        subject.authorized_scope(Post, action: 'custom?')
      end
    end
  end
end
