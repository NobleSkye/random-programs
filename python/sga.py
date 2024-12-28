import random

# a random program to learn the standard genetic alphabet

# Standard Galactic Alphabet
alphabet = {
    'a': 'ᔑ', 'b': 'ʖ', 'c': 'ᓵ', 'd': '↸', 'e': 'ᒷ', 'f': '⎓', 'g': '⊣', 'h': '⍑', 'i': '╎', 'j': '⋮',
    'k': 'ꖌ', 'l': 'ꖎ', 'm': 'ᒲ', 'n': 'リ', 'o': '𝙹', 'p': '!¡', 'q': 'ᑑ', 'r': '∷', 's': 'ᓭ', 't': 'ℸ ̣',
    'u': '⚍', 'v': '⍊', 'w': '∴', 'x': '̇/', 'y': '||', 'z': '⨅'
}

# Reverse mapping from SGA to English
reverse_alphabet = {v: k for k, v in alphabet.items()}

def translate_to_sga(text):
    return ''.join(alphabet.get(char, char) for char in text.lower())

def quiz():
    symbols = list(reverse_alphabet.keys())
    letters = list(alphabet.keys())
    random.shuffle(symbols)
    random.shuffle(letters)
    score = 0

    # SGA to English questions
    for symbol in symbols:
        print(f"What is the English letter for '{symbol}'?")
        answer = input("Your answer: ").lower()
        if answer == reverse_alphabet[symbol]:
            print("Correct!")
            score += 1
        else:
            print(f"Wrong! The correct answer is '{reverse_alphabet[symbol]}'")

    # English to SGA questions
    for letter in letters:
        print(f"What is the SGA symbol for '{letter}'?")
        answer = input("Your answer: ")
        if answer == alphabet[letter]:
            print("Correct!")
            score += 1
        else:
            print(f"Wrong! The correct answer is '{alphabet[letter]}'")

    print(f"Your final score is {score}/52")

if __name__ == "__main__":
    while True:
        print("\n1. Translate text to SGA")
        print("2. Take a quiz")
        print("3. Exit")
        choice = input("Choose an option: ")

        if choice == '1':
            text = input("Enter text to translate: ")
            print("Translated text:", translate_to_sga(text))
        elif choice == '2':
            quiz()
        elif choice == '3':
            break
        else:
            print("Invalid choice. Please try again.")