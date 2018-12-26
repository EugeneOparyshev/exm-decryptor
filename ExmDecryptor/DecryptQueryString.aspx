<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DecryptQueryString.aspx.cs" Inherits="ExmDecryptor.DecryptQueryString" %>
<%@ Import Namespace="Sitecore.Configuration" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Sitecore.IO" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="Sitecore.EmailCampaign" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="Sitecore.ExM.Framework.Helpers" %>
<%@ Import Namespace="ExmDecryptor" %>
<!DOCTYPE html>

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!keysEnableCheckBox.Checked)
        {
            textAuthenticationKey.Visible = false;
            textCryptographicKey.Visible = false;
            authenticationKey.Visible = false;
            cryptographicKey.Visible = false;
        }
        else
        {
            textAuthenticationKey.Visible = true;
            textCryptographicKey.Visible = true;
            authenticationKey.Visible = true;
            cryptographicKey.Visible = true;
        }
    }

    protected void Decrypt_Click(object sender, EventArgs e)
    {
        try
        {
            ResetValues();
            var encryptedString = Uri.UnescapeDataString(tbEncryptedQueryString.Text);
            var result = DecryptString(encryptedString);
            tbDecryptedQueryString.Text = string.IsNullOrEmpty(result) ? "Decryption was not successful" : Uri.UnescapeDataString(result);
        }
        catch (Exception ex)
        {
            lError.Visible = true;
            lError.Text = ex.Message;
        }
    }

    protected void DecryptFile_Click(object sender, System.EventArgs e)
    {
        if (FileUpload.HasFile)
            try
            {
                string encriptedString = TransformFileToString(FileUpload);
                var decriptedString = DecryptString(encriptedString);

                string makePath = Sitecore.IO.FileUtil.MakePath(Sitecore.Configuration.Settings.DataFolder, FileUpload.FileName);
                System.IO.File.WriteAllText(makePath + "_decrypted.txt", decriptedString);
                Label1.Text = String.Format("The decrypted file can be found here:{0}", makePath) + "_decrypted.txt";

            }
            catch (Exception ex)
            {
                Label1.Text = "ERROR: " + ex.Message.ToString();
            }
        else
        {
            Label1.Text = "You have not specified a file.";
        }
    }

    private string DecryptString(string encryptedString)
    {
        var unescapedEncryptedString = Uri.UnescapeDataString(encryptedString);
        Sitecore.Modules.EmailCampaign.Core.Crypto.AuthenticatedAesStringCipher cipher;
        if ((authenticationKey.Text.Length < 1 && cryptographicKey.Text.Length < 1) || (cryptographicKey.Text == ConfigurationManager.ConnectionStrings["EXM.CryptographicKey"].ConnectionString && authenticationKey.Text == ConfigurationManager.ConnectionStrings["EXM.AuthenticationKey"].ConnectionString))
        {
            cipher = Sitecore.Configuration.Factory.CreateObject("exmAuthenticatedCipher", true) as Sitecore.Modules.EmailCampaign.Core.Crypto.AuthenticatedAesStringCipher;
        }
        else
        {
            byte[] byteCriptographicKey;
            Sitecore.ExM.Framework.Helpers.ByteArray.TryParseHexString(cryptographicKey.Text, false, out byteCriptographicKey);
            byte[] byteAuthenticationKey;
            Sitecore.ExM.Framework.Helpers.ByteArray.TryParseHexString(authenticationKey.Text, false, out byteAuthenticationKey);
            cipher = new Sitecore.Modules.EmailCampaign.Core.Crypto.AuthenticatedAesStringCipher(byteCriptographicKey, byteAuthenticationKey);
        }

        return cipher.TryDecrypt(unescapedEncryptedString);
    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Decrypt</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <p>
                <asp:Label runat="server" Text="Check in the checkbox to enter EXM.CryptographicKey and EXM.AuthenticationKey which were used for encription. <br/>If these keys are not entered, the current ones from the App_Config/Connectionstrings.config are used. " Font-Bold="true" Font-Size="Medium" />
            </p>
            <p>
                <asp:CheckBox runat="server" Text=" " ID="keysEnableCheckBox"/>
                <asp:Button runat="server" Text="Confirm checkbox value change" />
            </p>
            
            <p>
                <asp:Label runat="server" ID="textCryptographicKey" AssociatedControlID="cryptographicKey" Text="EXM.CryptographicKey: " />
                <asp:TextBox runat="server" TextMode="SingleLine" ID="cryptographicKey" Style="width: 20%" />
            </p>
                <asp:Label runat="server" ID="textAuthenticationKey" AssociatedControlID="cryptographicKey" Text="EXM.AuthenticationKey: " />
                <asp:TextBox runat="server" TextMode="SingleLine" ID="authenticationKey" Style="width: 20%" />
            <p>

            </p>

            <br /><br /><br />
            <asp:Label runat="server" Text="Encrypt String: " Font-Bold="true" Font-Size="Medium" />
            <p>
                <asp:Label runat="server" AssociatedControlID="tbEncryptedQueryString" Text="Enter the encrypted query string (value after '?ec_eq=' ):" />
            </p>
            <p>
                <asp:TextBox runat="server" TextMode="MultiLine" ID="tbEncryptedQueryString" Style="width: 70%" />
            </p>
            <asp:Button runat="server" Text="Decrypt" OnClick="Decrypt_Click" />
            <p>
                <asp:Label runat="server" AssociatedControlID="tbDecryptedQueryString" Text="The decrypted query string: " />
            </p>
            <p>
                <asp:TextBox runat="server" ID="tbDecryptedQueryString" TextMode="MultiLine" Style="width: 70%" />
            </p>
            <p>
                <asp:Label runat="server" ID="lError" Visible="False" />
            </p>
            <p>
                </p>
        </div>
        <br /><br /><br />
        <asp:Label runat="server" Text="Encrypt File: " Font-Bold="true" Font-Size="Medium" />
        <div>
            <p>
                <asp:Label runat="server" AssociatedControlID="FileUpload" Text="Enter the file that contains from the encrypted data:" />
            </p>
            <p>
                <asp:FileUpload ID="FileUpload" runat="server" /><br />
            </p>
        <br />
        <asp:Button runat="server" Text="Decrypt File" OnClick="DecryptFile_Click" />            
         <br />
        <br />
        <asp:Label ID="Label1" runat="server"></asp:Label></div>
    </form>
</body>
</html>