using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace ExmDecryptor
{
    public partial class DecryptQueryString : System.Web.UI.Page
    {
        public void ResetValues()
        {
            tbDecryptedQueryString.Text = "";
            lError.Text = "";
        }        

        public string TransformFileToString(FileUpload file)
        {
            var myStream = file.FileContent;
            var fileUploadLength = FileUpload.PostedFile.ContentLength;
            Byte[] input = new Byte[fileUploadLength];
            StringBuilder fileUploadString = new StringBuilder();
            myStream.Read(input, 0, fileUploadLength);
            for (int loop1 = 0; loop1 < fileUploadLength; loop1++)
            {
                var currentChar = (char)input[loop1];
                fileUploadString.Append(currentChar.ToString());
            }
            return fileUploadString.ToString();
        }        
    }
}