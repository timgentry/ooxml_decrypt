$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))

require "ooxml_decrypt"
require "optparse"

def program_name
  File.basename(File.expand_path(__FILE__))
end

def parse_args(args=ARGV)
  options = {}

  @optparser = OptionParser.new(args) do |opts|
    opts.banner = "Usage: #{program_name} [options]"

    opts.on("-e", "--source <path>", "Path to encrypted file") do |filename|
      options[:enc_filename] = filename
    end

    opts.on("-d", "--destination <path>", "Path to write decrypted file (if omitted, will append '.decrypted' to source filename") do |filename|
      options[:dec_filename] = filename
    end

    opts.on("-p", "--password <password>", "Password to decrypt file (if omitted, will prompt)") do |password|
      options[:password] = password
    end
  end

  begin @optparser.parse! args
  rescue OptionParser::InvalidOption => e
    puts e
    puts optparser
    exit(1)
  end

  return options
end

def puts_usage
  puts @optparser
end




options = parse_args()
unless options[:enc_filename]
  warn "Source (encrypted) filename is required"
  puts_usage
  exit(1)
end

unless options[:password]
  require "io/console"
  print "Password: "
  options[:password] = STDIN.noecho(&:gets).chomp
end

unless options[:dec_filename]
  options[:dec_filename] = options[:enc_filename] + ".decrypted"
end

# Ensure password is a binary representation of a UTF-16LE string
# e.g. 'password' should be represented as "p\0\a\s\0[...]"
password = options[:password].encode("utf-16le")
                             .bytes.pack("c*")
                             .encode("binary")

OoxmlDecrypt::EncryptedFile.decrypt_to_file( options[:enc_filename], password, options[:dec_filename] )
