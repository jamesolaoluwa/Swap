"""Email templates for $wap notifications."""

from app.config import settings


def welcome_email(user_name: str, skills_to_offer: str, services_needed: str) -> dict:
    """Generate welcome email content."""
    name = user_name or "there"
    offers = skills_to_offer or "Not set yet"
    needs = services_needed or "Not set yet"

    subject = "Welcome to $wap!"

    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 10px 10px 0 0;">
            <h1 style="color: white; margin: 0; font-size: 28px;">Welcome to $wap!</h1>
        </div>

        <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
            <p style="font-size: 18px;">Hey {name},</p>

            <p>You're in! <strong>$wap</strong> connects you with people for skill exchanges. No money needed - just swap what you know for what you want to learn.</p>

            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #667eea;">
                <p style="margin: 0 0 10px 0; font-weight: 600;">Your profile:</p>
                <p style="margin: 5px 0;"><strong>You can teach:</strong> {offers}</p>
                <p style="margin: 5px 0;"><strong>You want to learn:</strong> {needs}</p>
            </div>

            <p>We'll notify you when we find great matches - people who want to learn what you teach, and can teach what you want to learn.</p>

            <div style="text-align: center; margin: 30px 0;">
                <a href="{settings.app_url}" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 14px 30px; text-decoration: none; border-radius: 25px; font-weight: 600; display: inline-block;">Find Your First Match</a>
            </div>

            <p style="color: #666; font-size: 14px;">Happy swapping!<br>The $wap Team</p>
        </div>

        <div style="text-align: center; padding: 20px; color: #999; font-size: 12px;">
            <p>You're receiving this because you signed up for $wap.<br>
            <a href="{settings.app_url}/settings" style="color: #667eea;">Manage email preferences</a></p>
        </div>
    </body>
    </html>
    """

    text = f"""
Welcome to $wap!

Hey {name},

You're in! $wap connects you with people for skill exchanges.

Your profile:
- You can teach: {offers}
- You want to learn: {needs}

We'll notify you when we find great matches.

Find your first match: {settings.app_url}

Happy swapping!
The $wap Team
    """

    return {"subject": subject, "html": html, "text": text}


def swap_request_email(
    recipient_name: str,
    requester_name: str,
    requester_offers: str,
    requester_needs: str,
    message: str,
    request_id: str,
) -> dict:
    """Generate swap request notification email content."""
    name = recipient_name or "there"
    r_name = requester_name or "Someone"
    r_offers = requester_offers or "Various skills"
    r_needs = requester_needs or "Various skills"
    intro_msg = message or ""

    subject = f"New swap request from {r_name}"

    message_section = ""
    if intro_msg:
        message_section = f"""
                <div style="background: #f0f0f0; padding: 15px; border-radius: 8px; margin-top: 15px; font-style: italic;">
                    "{intro_msg}"
                </div>
        """

    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 10px 10px 0 0;">
            <h1 style="color: white; margin: 0; font-size: 24px;">New Swap Request!</h1>
        </div>

        <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
            <p style="font-size: 18px;">Hey {name},</p>

            <p><strong>{r_name}</strong> wants to swap skills with you!</p>

            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border: 1px solid #e0e0e0;">
                <div style="display: flex; align-items: center; margin-bottom: 15px;">
                    <div style="width: 50px; height: 50px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 20px;">{r_name[0].upper()}</div>
                    <div style="margin-left: 15px;">
                        <p style="margin: 0; font-weight: 600; font-size: 18px;">{r_name}</p>
                    </div>
                </div>

                <div style="border-top: 1px solid #eee; padding-top: 15px;">
                    <p style="margin: 5px 0;"><strong>They can teach you:</strong> {r_offers}</p>
                    <p style="margin: 5px 0;"><strong>They want to learn:</strong> {r_needs}</p>
                </div>
                {message_section}
            </div>

            <div style="text-align: center; margin: 30px 0;">
                <a href="{settings.app_url}/requests" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 14px 30px; text-decoration: none; border-radius: 25px; font-weight: 600; display: inline-block;">View Request</a>
            </div>

            <p style="color: #666; font-size: 14px;">Happy swapping!<br>The $wap Team</p>
        </div>

        <div style="text-align: center; padding: 20px; color: #999; font-size: 12px;">
            <p>You're receiving this because you have email notifications enabled.<br>
            <a href="{settings.app_url}/settings" style="color: #667eea;">Manage email preferences</a></p>
        </div>
    </body>
    </html>
    """

    text = f"""
New Swap Request!

Hey {name},

{r_name} wants to swap skills with you!

They can teach you: {r_offers}
They want to learn: {r_needs}
{f'Message: "{intro_msg}"' if intro_msg else ''}

View the request: {settings.app_url}/requests

Happy swapping!
The $wap Team
    """

    return {"subject": subject, "html": html, "text": text}


def swap_accepted_email(
    requester_name: str,
    recipient_name: str,
    conversation_id: str,
) -> dict:
    """Generate swap accepted notification email content."""
    name = requester_name or "there"
    r_name = recipient_name or "Someone"

    subject = f"{r_name} accepted your swap request!"

    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); padding: 30px; border-radius: 10px 10px 0 0;">
            <h1 style="color: white; margin: 0; font-size: 24px;">Swap Accepted!</h1>
        </div>

        <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
            <p style="font-size: 18px;">Hey {name},</p>

            <p>Great news! <strong>{r_name}</strong> accepted your swap request!</p>

            <p>You can now start chatting to arrange your skill exchange. Discuss schedules, set expectations, and get ready to learn something new!</p>

            <div style="text-align: center; margin: 30px 0;">
                <a href="{settings.app_url}/messages/{conversation_id}" style="background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); color: white; padding: 14px 30px; text-decoration: none; border-radius: 25px; font-weight: 600; display: inline-block;">Start Chatting</a>
            </div>

            <p style="color: #666; font-size: 14px;">Happy swapping!<br>The $wap Team</p>
        </div>

        <div style="text-align: center; padding: 20px; color: #999; font-size: 12px;">
            <p>You're receiving this because you have email notifications enabled.<br>
            <a href="{settings.app_url}/settings" style="color: #667eea;">Manage email preferences</a></p>
        </div>
    </body>
    </html>
    """

    text = f"""
Swap Accepted!

Hey {name},

Great news! {r_name} accepted your swap request!

You can now start chatting to arrange your skill exchange.

Start chatting: {settings.app_url}/messages/{conversation_id}

Happy swapping!
The $wap Team
    """

    return {"subject": subject, "html": html, "text": text}


def swap_declined_email(
    requester_name: str,
    recipient_name: str,
) -> dict:
    """Generate swap declined notification email content."""
    name = requester_name or "there"
    r_name = recipient_name or "Someone"

    subject = f"Update on your swap request"

    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 10px 10px 0 0;">
            <h1 style="color: white; margin: 0; font-size: 24px;">Swap Request Update</h1>
        </div>

        <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
            <p style="font-size: 18px;">Hey {name},</p>

            <p><strong>{r_name}</strong> wasn't able to accept your swap request at this time.</p>

            <p>Don't worry - there are plenty of other people on $wap looking to exchange skills! Keep exploring and you'll find your perfect match.</p>

            <div style="text-align: center; margin: 30px 0;">
                <a href="{settings.app_url}" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 14px 30px; text-decoration: none; border-radius: 25px; font-weight: 600; display: inline-block;">Find More Matches</a>
            </div>

            <p style="color: #666; font-size: 14px;">Happy swapping!<br>The $wap Team</p>
        </div>

        <div style="text-align: center; padding: 20px; color: #999; font-size: 12px;">
            <p>You're receiving this because you have email notifications enabled.<br>
            <a href="{settings.app_url}/settings" style="color: #667eea;">Manage email preferences</a></p>
        </div>
    </body>
    </html>
    """

    text = f"""
Swap Request Update

Hey {name},

{r_name} wasn't able to accept your swap request at this time.

Don't worry - there are plenty of other people on $wap looking to exchange skills!

Find more matches: {settings.app_url}

Happy swapping!
The $wap Team
    """

    return {"subject": subject, "html": html, "text": text}


def new_message_email(
    recipient_name: str,
    sender_name: str,
    message_preview: str,
    conversation_id: str,
) -> dict:
    """Generate new message notification email content."""
    name = recipient_name or "there"
    s_name = sender_name or "Someone"
    preview = message_preview[:100] + ("..." if len(message_preview) > 100 else "")

    subject = f"New message from {s_name}"

    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 10px 10px 0 0;">
            <h1 style="color: white; margin: 0; font-size: 24px;">New Message</h1>
        </div>

        <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
            <p style="font-size: 18px;">Hey {name},</p>

            <p><strong>{s_name}</strong> sent you a message:</p>

            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #667eea;">
                <p style="margin: 0; font-style: italic; color: #555;">"{preview}"</p>
            </div>

            <div style="text-align: center; margin: 30px 0;">
                <a href="{settings.app_url}/messages/{conversation_id}" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 14px 30px; text-decoration: none; border-radius: 25px; font-weight: 600; display: inline-block;">Reply</a>
            </div>

            <p style="color: #666; font-size: 14px;">Happy swapping!<br>The $wap Team</p>
        </div>

        <div style="text-align: center; padding: 20px; color: #999; font-size: 12px;">
            <p>You're receiving this because you have email notifications enabled.<br>
            <a href="{settings.app_url}/settings" style="color: #667eea;">Manage email preferences</a></p>
        </div>
    </body>
    </html>
    """

    text = f"""
New Message

Hey {name},

{s_name} sent you a message:

"{preview}"

Reply: {settings.app_url}/messages/{conversation_id}

Happy swapping!
The $wap Team
    """

    return {"subject": subject, "html": html, "text": text}


def match_notification_email(
    user_name: str,
    match_name: str,
    match_offers: str,
    match_needs: str,
    score: float,
    match_uid: str,
) -> dict:
    """Generate match notification email content."""
    name = user_name or "there"
    m_name = match_name or "Someone"
    m_offers = match_offers or "Various skills"
    m_needs = match_needs or "Various skills"
    score_pct = int(score * 100)

    subject = f"New skill swap match: {m_name}"

    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); padding: 30px; border-radius: 10px 10px 0 0;">
            <h1 style="color: white; margin: 0; font-size: 24px;">New Match Found!</h1>
        </div>

        <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
            <p style="font-size: 18px;">Hey {name},</p>

            <p>Great news! We found a strong skill swap match for you.</p>

            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border: 1px solid #e0e0e0;">
                <div style="display: flex; align-items: center; margin-bottom: 15px;">
                    <div style="width: 50px; height: 50px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 20px;">{m_name[0].upper()}</div>
                    <div style="margin-left: 15px;">
                        <p style="margin: 0; font-weight: 600; font-size: 18px;">{m_name}</p>
                        <p style="margin: 0; color: #11998e; font-weight: 600;">{score_pct}% match</p>
                    </div>
                </div>

                <div style="border-top: 1px solid #eee; padding-top: 15px;">
                    <p style="margin: 5px 0;"><strong>They can teach:</strong> {m_offers}</p>
                    <p style="margin: 5px 0;"><strong>They want to learn:</strong> {m_needs}</p>
                </div>
            </div>

            <p>This could be a perfect swap - you each have something the other wants!</p>

            <div style="text-align: center; margin: 30px 0;">
                <a href="{settings.app_url}/profile/{match_uid}" style="background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); color: white; padding: 14px 30px; text-decoration: none; border-radius: 25px; font-weight: 600; display: inline-block;">View Profile</a>
            </div>

            <p style="color: #666; font-size: 14px;">Happy swapping!<br>The $wap Team</p>
        </div>

        <div style="text-align: center; padding: 20px; color: #999; font-size: 12px;">
            <p>You're receiving this because you have email notifications enabled.<br>
            <a href="{settings.app_url}/settings" style="color: #667eea;">Manage email preferences</a></p>
        </div>
    </body>
    </html>
    """

    text = f"""
New Match Found!

Hey {name},

Great news! We found a strong skill swap match for you.

{m_name} - {score_pct}% match

They can teach: {m_offers}
They want to learn: {m_needs}

This could be a perfect swap!

View their profile: {settings.app_url}/profile/{match_uid}

Happy swapping!
The $wap Team
    """

    return {"subject": subject, "html": html, "text": text}
