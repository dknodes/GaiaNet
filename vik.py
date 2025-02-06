from trivia_api import Trivia
trivia = Trivia()
question = trivia.get_random_question()
print(question["question"])