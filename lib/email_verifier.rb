require_relative "inbox"

class EmailVerifier
  attr_reader :missing_alerts, :emailed_alerts, :acknowledged_alerts

  TO_EMAIL = "govuk_email_check@digital.cabinet-office.gov.uk".freeze
  FROM_EMAIL = "gov.uk.email@notifications.service.gov.uk".freeze
  ACKNOWLEDGED_EMAIL_CONTENTS = [
    %{subject:"Philips sterilizable defibrillator internal paddles (specific models) – may fail to deliver therapy if pre-use checks are not followed (MDA/2020/022)"},
    %{subject:"Imatinib 400mg Capsules (3 x 10)  PL 36390/0180 : Company-led Drug Alert"},
    %(subject:"Field Safety Notice - 17 September to  21 September"),
    %{subject:"Various trauma guide wires – risk of infection due to packaging failure (MDA/2018/032)"},
    %{subject:"SureSigns VS & VM patient monitors and Viewing stations manufactured before May 2018: risk of batteries overheating or igniting (MDA/2018/031)"},
    %{subject:"Flex connectors in Halyard Closed Suction Kits – risk of interruption of ventilation (MDA/2018/030)"},
    %(subject:"Field safety notices - 26 to 30 November 2018"),
    %(subject:"Field Safety Notice - 19 November to 23 November 2018"),
    %{subject:"Implantable cardiac pacemakers: specific brands of dual chamber pacemakers - risk of syncope due to pause in pacing therapy (MDA/2019/008)"},
    %{subject:"Drug Alert Class 4: Paracetamol Infusion, Accord. (MDR 07-02/19)"},
    %(subject:"Field Safety Notice: 8 to 12 April 2019"),
    %(subject:"Field Safety Notice: 15 to 19 April 2019"),
    %{subject:"Aisys and Aisys CS2 anaesthesia devices with Et Control option and software versions 11, 11SP01 and 11SP02 – risk of patient awareness due to inadequate anaesthesia (MDA/2019/022)"},
    %{subject:"Professional use defibrillator/monitor: Efficia DFM100 (Model number 866199)  – risk of failure to switch on or unexpected restart (MDA/2019/039)"},
    %{subject:"Class 2 Medicines recall: Emerade 150, 300 and 500 microgram solution for injection in pre-filled syringe (EL(19)A/39)"},
    %{subject:"Professional use defibrillator/monitor: all HeartStart XL+ (Model number 861290) - risk of failure to deliver therapy (MDA/2020/003)"},
    %{subject:"Company led drug alert – Iohexol solution for injection (350mg/ml and 300 mgI/ml)"},
    %{subject:"Class 4 Medicines Defect Information: Memantine 10mg Film-Coated Tablets, PL 20416/0260, (EL (20)A/11)"},
    %{subject:"All T34 and T34L (T60) ambulatory syringe pumps – check pumps before each use due to risk of under-infusion and no alarm (MDA/2020/007)"},
    %{subject:"Various Olympus duodenoscope models: do not use if elevator wires are frayed or damaged as these may cause lacerations to patients and users (MDA/2020/008) "},
    %(" 2:21pm, 8 June 2020" subject:"South Sudan travel advice"),
    %(" 2:20pm, 8 June 2020" subject:"Venezuela travel advice"),
    %(" 2:19pm, 8 June 2020" subject:"Uruguay travel advice"),
  ].freeze

  def initialize
    @emailed_alerts = []
    @acknowledged_alerts = []
    @missing_alerts = []
    @inbox = Inbox.new
  end

  def have_all_alerts_been_emailed?
    @missing_alerts.empty?
  end

  def run_report
    email_search_queries.all? do |email_search_query|
      if has_email_address_received_email_with_contents?(contents: email_search_query)
        @emailed_alerts << [TO_EMAIL, FROM_EMAIL, email_search_query]
      elsif acknowledged_as_missing?(contents: email_search_query)
        @acknowledged_alerts << [TO_EMAIL, FROM_EMAIL, email_search_query]
      else
        @missing_alerts << [TO_EMAIL, FROM_EMAIL, email_search_query]
      end
    end
  end

private

  attr_reader :inbox

  def has_email_address_received_email_with_contents?(contents:)
    query = "#{contents} from:#{FROM_EMAIL} to:#{TO_EMAIL}"
    result = inbox.message_count_for_query(query)
    result != 0
  end

  def acknowledged_as_missing?(contents:)
    ACKNOWLEDGED_EMAIL_CONTENTS.include?(contents)
  end
end
