module UsersHelper
    def gender_label(gender)
        case gender
        when 1
            "Male"
        when 2
            "Female"
        when 3
            "Other"
        else
            "Not specified"
        end
    end
end
