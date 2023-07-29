

import 'package:flutter/material.dart';

class PrivacyPolicy {

  static const String policy =
"""
  VibraBraille is a camera captured image to a braille representation application.
  As you use our service, the information provided may be collected, shared, and stored. Please continue to read our policy for more details.
  \nCollecting
  We collect: Information provided by you and information is collected as you use our services.
  
  Information Provided by you
  Our Service requires each individual to set up an account that includes details you provide such as, username, password, email address, and phone number. This information is collected in order for you to have your own unique account.
  The text depicted in the photographs you take is also information we collect as it is sent through our service.
  Communication with us (customer support) will also be a time where we collect information that you provide us in order to assist any questions or concerns you may have.
  Information as you use our service
  While using our service, we collect information about which functionality, when, and how you’ve used the VibraBraille service. For example, when you have taken a photograph of text and which translations get saved as notes.
  •	Usage: Your activity throughout our services is information we may collect. Such as, how you interact with our services, including the photos you take, the changes in title name, or which search images you take and save to notes.
  •	Content: We collect content created by you while using our service, such as custom name titles for your braille translation note and photographs taken while using our service.
  
  •	Device: We collect information about the device you are using while engaging with our service. We collect, for example:
  •information about your devices’ hardware and software, things like hardware model, operating system version, device memory, unique application identifiers, unique device identifiers, and device usage data.
  •	information from sensors on your device, may include accelerometers, gyroscopes, compasses, microphones, camera flash, and the number of cameras your device has.
  •	Camera, Photos, and Audio. Our service requires us to collect images and information from the device’s camera and photos that is used to interact with our service. In order to take and send your image for braille translations, we need access to your camera or photos.
  
  What is done with the Information collected
  With the collected information we will:
  •	continue to improve, develop, maintain, deliver, and ultimately protect our service.
  •	send you communications through email when permitted. Particularly, we use email for verification that your email is valid by sending a one-time pass code. We also will respond to any type of support inquiries.
  •	to enhance the safety and security of our service.
  •	verify your email address is valid and within your access in order to prevent fraud or other unauthorized/illegal activity.
  How collected Information is shared
  The following list the ways we may share the information collected:
  \t•	With the general public or official personnel: We may have to share the following information if required to do so:
  \t•	We may share information about your device and usage information, for example to help us and others prevent fraud.
  \t•	We may share the collected information for any legal, safety, and security reasons. Sharing this information would only occur if we reasonably believed disclosing your information is needed for some of the following reasons:
  \t•	comply with any valid legal process, governmental request, or applicable law, rule, or regulation.
  \t•	investigate, remedy, or enforce potential violations of Terms and Conditions of Service.
  \t•	protect the rights, property, or safety of us, our users, or others.
  \t•	detect and resolve any fraud or security concerns.
  Third-Party Integrations
  Our services contain third-party integrations. Examples include third-party integrations in the Camera, account Authentication, Emails sent out with one-time passcode, and Image text analysis. We are not responsible for how the third parties collect and/or use your information.
  
  How Long collected Information is kept
  •	Saving images text created as notes will not be deleted until you delete them.
  •	Basic account information stored including your username, phone number, and email address will be delete at any time when you ask for your account to be deleted. This includes any and all data associate with your account.
  We cannot promise deletion will occur within a specific time frame. If we are presented with legal requirements to continue to store your data, we may need to suspend our deletion practices. For example, if we receive valid legal process asking us to preserve any image content, if we receive reports of abuse or Terms of Service violations, or if your account or content created by you is flagged by our systems for abuse or other Terms of Service violations. We may retain certain information in a backup for a very limited period of time or as instructed/required by law.
  Controlling Your Information
  We provide you with the following tools:
  •	Revoking permissions: You can revoke any and all permissions in your device’s settings if of course, offered by your device. However, you may lose functionality.
  •	Deletion: You can contact us at any point to delete your account, no questions asked. You can delete some information through our app, for example, notes that have been created and saved by you.
  
  Children
  Our services are not intended for anyone under the age of 13.  We do not knowingly collect personal information from anyone under the age of 13 due to its intended audience not being for those under 13. If we need consent to fulfill a legal basis for the processing of your information and/or your country requires consent from a parent/ guardian, we may require your parent/guardians consent before any collection or use of information.
  \nRevisions to the Privacy Policy
  This Privacy Policy may need revisions from time to time. We will let you know in the following ways:
  •	Change in the date under the Privacy Policy header available to you through our website or at the bottom of login page of the application.
  •	You may get an in-app notification of the revisions to our privacy policy
""";
  late BuildContext context;

  PrivacyPolicy(BuildContext currentContext) {
    context = currentContext;
}
  Container getPolicyText() {
    return Container( padding: const EdgeInsets.only(bottom: 20),
        child:
        GestureDetector(
      onTap: () => {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              scrollable: true,
                title: const Text('Privacy Policy\nEffective on August 6, 2022', semanticsLabel: "Privacy Policy",
                  style: TextStyle(fontSize: 20),),
                content: const Text(policy, semanticsLabel: policy,
                  style: TextStyle(fontSize: 14),),
                actions: <Widget>[
                  TextButton(
                    onPressed: () =>  { Navigator.pop(context, 'Cancel')
                    },
                    child: const Text('Okay', semanticsLabel: "Okay", style: TextStyle(fontSize: 20),),
                  )]
            );})
        },
      child: Row(  mainAxisAlignment: MainAxisAlignment.center,
          children: const [
        Text("Please review our ",
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,),
      Text(" Privacy Policy", semanticsLabel: "Please review our Privacy Policy",
        style: TextStyle(color: Colors.blue, fontSize: 19, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,)])
    ));
  }

}