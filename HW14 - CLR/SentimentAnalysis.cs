using System;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Collections.Generic;
using System.Linq;

public class SentimentAnalysis
{
    private static readonly HashSet<string> PositiveRoots = new HashSet<string>
    {
        "мудр", "светл", "полезн", "глубок", "вдохнов", "важн", "значим", "познав", "гармон", "просветл", "добр", "осозн", "умиротвор", "интерес", "увлек", "развива", "мотивир", "хорош", "прекрасн", "замечательн", "отличн", "великолепн", "потрясающ", "гениальн", "помо", "подоб", "задум"
    };

    private static readonly HashSet<string> NegativeRoots = new HashSet<string>
    {
        "скучн", "поверхност", "нудн", "разочар", "неинтерес", "бесполез", "сложн", "запут", "мутор", "тягомот", "однообраз", "скудн", "ужасн", "плох", "негативн", "раздражающ", "нелеп", "слаб", "глуп", "бред", "непонятн"
    };

    private static readonly HashSet<string> NegationWords = new HashSet<string>
    {
        "не", "нет", "никогда", "ни", "без"
    };

    private const int NeutralThreshold = 2;

    [SqlFunction]
    public static SqlString AnalyzeSentiment(SqlString text)
    {
        if (text.IsNull) return SqlString.Null;

        string review = text.Value.ToLower();
        int positiveScore = 0;
        int negativeScore = 0;
        string[] words = review.Split(new char[] { ' ', ',', '.', '!', '?' }, StringSplitOptions.RemoveEmptyEntries);

        for (int i = 0; i < words.Length; i++)
        {
            bool negation = (i > 0 && NegationWords.Contains(words[i - 1]));

            if (PositiveRoots.Any(root => words[i].StartsWith(root)))
            {
                positiveScore += negation ? -1 : 1;
            }
            else if (NegativeRoots.Any(root => words[i].StartsWith(root)))
            {
                negativeScore += negation ? -1 : 2;
            }
        }

        int finalScore = positiveScore - negativeScore;
        if (finalScore >= NeutralThreshold) return "Положительный";
        if (finalScore <= -NeutralThreshold) return "Отрицательный";
        return "Нейтральный";
    }
}
