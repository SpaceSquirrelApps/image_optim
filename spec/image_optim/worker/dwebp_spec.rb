# frozen_string_literal: true

require 'spec_helper'
require 'image_optim/worker/dwebp'

describe ImageOptim::Worker::Dwebp do
  describe '#image_formats' do
    subject{ described_class.new(ImageOptim.new, {}).image_formats }

    it{ is_expected.to eq([:png]) }
  end

  describe '#run_order' do
    subject{ described_class.new(ImageOptim.new, {}).run_order }

    it{ is_expected.to eq(-5) }
  end

  describe '#optimize' do
    subject{ described_class.new(ImageOptim.new, {}) }

    let(:src){ instance_double(ImageOptim::Path, to_s: '/tmp/src.webp') }
    let(:dst){ instance_double(ImageOptim::Path, to_s: '/tmp/dst.png') }

    before do
      allow(subject).to receive(:resolve_bin!)
      allow(subject).to receive(:execute).and_return(true)
    end

    context 'when source is a webp file' do
      it 'executes dwebp command' do
        expect(subject).to receive(:execute) do |bin, args, _opts|
          expect(bin).to eq(:dwebp)
          expect(args.join(' ')).to include('/tmp/src.webp')
          expect(args.join(' ')).to include('-o /tmp/dst.png')
          true
        end

        subject.optimize(src, dst)
      end
    end

    context 'when source is not a webp file' do
      let(:src){ instance_double(ImageOptim::Path, to_s: '/tmp/src.png') }

      it 'returns false without executing' do
        expect(subject).not_to receive(:execute)
        expect(subject.optimize(src, dst)).to eq(false)
      end
    end
  end
end
