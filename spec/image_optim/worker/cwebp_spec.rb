# frozen_string_literal: true

require 'spec_helper'
require 'image_optim/worker/cwebp'

describe ImageOptim::Worker::Cwebp do
  describe '#image_formats' do
    subject{ described_class.new(ImageOptim.new, {}).image_formats }

    it{ is_expected.to eq([:webp]) }
  end

  describe 'quality option' do
    describe 'default' do
      subject{ described_class::QUALITY_OPTION.default }

      it{ is_expected.to eq(75) }
    end

    describe 'value' do
      let(:subject){ described_class.new(ImageOptim.new, options).quality }

      context 'when lossy not allowed' do
        context 'by default' do
          let(:options){ {} }

          it{ is_expected.to eq(75) }
        end

        context 'when value is passed through options' do
          let(:options){ {quality: 50} }

          it 'warns and keeps default' do
            expect_any_instance_of(described_class).
              to receive(:warn).with(/ignored in lossless mode/)
            is_expected.to eq(75)
          end
        end
      end

      context 'when lossy allowed' do
        context 'by default' do
          let(:options){ {allow_lossy: true} }

          it{ is_expected.to eq(75) }
        end

        context 'when value is passed through options' do
          let(:options){ {allow_lossy: true, quality: 90} }

          it 'sets the value without warning' do
            expect_any_instance_of(described_class).not_to receive(:warn)
            is_expected.to eq(90)
          end
        end

        context 'when passed value is less than 0' do
          let(:options){ {allow_lossy: true, quality: -50} }

          it 'sets to 0' do
            is_expected.to eq(0)
          end
        end

        context 'when passed value is more than 100' do
          let(:options){ {allow_lossy: true, quality: 150} }

          it 'sets to 100' do
            is_expected.to eq(100)
          end
        end
      end
    end
  end

  describe 'method option' do
    describe 'default' do
      subject{ described_class::METHOD_OPTION.default }

      it{ is_expected.to eq(4) }
    end

    describe 'value' do
      let(:subject){ described_class.new(ImageOptim.new, options).method }

      context 'by default' do
        let(:options){ {} }

        it{ is_expected.to eq(4) }
      end

      context 'when value is less than 0' do
        let(:options){ {method: -1} }

        it 'sets to 0' do
          is_expected.to eq(0)
        end
      end

      context 'when value is more than 6' do
        let(:options){ {method: 10} }

        it 'sets to 6' do
          is_expected.to eq(6)
        end
      end
    end
  end

  describe 'alpha_quality option' do
    describe 'default' do
      subject{ described_class::ALPHA_QUALITY_OPTION.default }

      it{ is_expected.to eq(100) }
    end

    describe 'value' do
      let(:subject){ described_class.new(ImageOptim.new, options).alpha_quality }

      context 'by default' do
        let(:options){ {} }

        it{ is_expected.to eq(100) }
      end

      context 'when value is less than 0' do
        let(:options){ {alpha_quality: -50} }

        it 'sets to 0' do
          is_expected.to eq(0)
        end
      end

      context 'when value is more than 100' do
        let(:options){ {alpha_quality: 150} }

        it 'sets to 100' do
          is_expected.to eq(100)
        end
      end
    end
  end

  describe 'strip option' do
    subject{ described_class.new(ImageOptim.new, options) }

    let(:options){ {} }
    let(:src){ instance_double(ImageOptim::Path, to_s: '/tmp/src.webp') }
    let(:dst){ instance_double(ImageOptim::Path, to_s: '/tmp/dst.webp') }

    before do
      allow(subject).to receive(:resolve_bin!)
      allow(subject).to receive(:optimized?)
    end

    context 'by default (strip all)' do
      it 'should add -metadata none to arguments' do
        expect(subject).to receive(:execute) do |_bin, *args|
          expect(args.join(' ')).to match(/(^| )-metadata none($| )/)
        end

        subject.optimize(src, dst)
      end
    end

    context 'when strip is :none' do
      let(:options){ {strip: :none} }

      it 'should add -metadata all to keep all metadata' do
        expect(subject).to receive(:execute) do |_bin, *args|
          expect(args.join(' ')).to match(/(^| )-metadata all($| )/)
        end

        subject.optimize(src, dst)
      end
    end

    context 'when strip is [:exif]' do
      let(:options){ {strip: [:exif]} }

      it 'should keep icc and xmp metadata' do
        expect(subject).to receive(:execute) do |_bin, *args|
          args_string = args.join(' ')
          expect(args_string).to match(/(^| )-metadata (icc,xmp|xmp,icc)($| )/)
        end

        subject.optimize(src, dst)
      end
    end
  end

  describe 'optimize' do
    subject{ described_class.new(ImageOptim.new, options) }

    let(:src){ instance_double(ImageOptim::Path, to_s: '/tmp/src.webp') }
    let(:dst){ instance_double(ImageOptim::Path, to_s: '/tmp/dst.webp') }

    before do
      allow(subject).to receive(:resolve_bin!)
      allow(subject).to receive(:optimized?).and_return(true)
    end

    context 'when lossy not allowed (lossless mode)' do
      let(:options){ {} }

      it 'should add -lossless to arguments' do
        expect(subject).to receive(:execute) do |_bin, *args|
          expect(args.join(' ')).to match(/(^| )-lossless($| )/)
        end

        subject.optimize(src, dst)
      end

      it 'should not add -q to arguments' do
        expect(subject).to receive(:execute) do |_bin, *args|
          expect(args.join(' ')).not_to match(/(^| )-q($| )/)
        end

        subject.optimize(src, dst)
      end
    end

    context 'when lossy allowed' do
      let(:options){ {allow_lossy: true, quality: 80} }

      it 'should add -q with quality to arguments' do
        expect(subject).to receive(:execute) do |_bin, *args|
          expect(args.join(' ')).to match(/(^| )-q 80($| )/)
        end

        subject.optimize(src, dst)
      end

      it 'should not add -lossless to arguments' do
        expect(subject).to receive(:execute) do |_bin, *args|
          expect(args.join(' ')).not_to match(/(^| )-lossless($| )/)
        end

        subject.optimize(src, dst)
      end
    end
  end
end
