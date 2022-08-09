function indigo-code-artifact-login -d "authenticate with AWS and setup CodeArtifact credentials"
    # get password and username from 1 password
    set username (op item get indigo --fields username)
    set password (op item get indigo --fields password)
    # copy one time pasword to clipboard
    set clipboard (pbpaste)
    op item get indigo --otp | pbcopy
    # authenticate with AWS
    echo "authenticating $username with saml2aws"
    saml2aws --username $username --password $password --skip-prompt login
    # configure codeartifact credentials
    echo "configuring code artifact credentials"
    dev-cli configure --code-artifact $argv
    # restore clipboard
    echo $clipboard | pbcopy
end
