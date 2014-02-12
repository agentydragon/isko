require 'isko/days'

module Isko
	module TimetableReporter
		def self.report_results(agent, result, file)
			shown = result[:slots].map { |slot|
				s = {
					day: slot.start_day,
					start: slot.absolute_start_in_minutes,
					length: slot.duration_minutes,
					code: slot.code,
					subject_code: slot.subject_code,
					type: slot.type,
					teacher: slot.teacher,
				}
				s[:subject_name] = agent.get_subject_name(slot.subject_code)
				s
			}

			outside_slots = result[:outside_slots].reject(&:weird?).map { |slot|
				s = {
					day: slot.start_day,
					start: slot.absolute_start_in_minutes,
					length: slot.duration_minutes,
					code: slot.code,
					subject_code: slot.subject_code,
					type: slot.type,
					teacher: slot.teacher,
				}
				s[:subject_name] = agent.get_subject_name(slot.subject_code)
				s
			}

			subjects = result[:subjects].map { |subject|
				{
					code: subject,
					name: agent.get_subject_name(subject),
					credits: agent.get_subject_credits(subject),
					slots: shown.select { |s| s[:subject_code] == subject.to_s }
				}
			}

			hash = {
				shown: shown,
				subjects: subjects,
				objective: result[:objective],
				outside_slots: outside_slots,
				raw_output: result[:raw_output]
			}

			eng = Haml::Engine.new(File.read('_template.html.haml'))
			File.write(file, eng.render(Object.new, hash))
		end
	end
end
