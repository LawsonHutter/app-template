import 'package:flutter/material.dart';
import 'survey_screen.dart';

class QuestionPage extends StatelessWidget {
  final QuestionData question;
  final int? selectedAnswerId;
  final Function(int) onAnswerSelected;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool isLastQuestion;

  const QuestionPage({
    super.key,
    required this.question,
    this.selectedAnswerId,
    required this.onAnswerSelected,
    this.onNext,
    this.onPrevious,
    required this.isLastQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question text
            Expanded(
              child: Center(
                child: Text(
                  question.text,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        height: 1.3,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Answer choices
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: question.answers.length,
                itemBuilder: (context, index) {
                  final answer = question.answers[index];
                  final isSelected = selectedAnswerId == answer.id;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.cyan
                              : const Color(0xFF2D2D2D),
                          width: isSelected ? 2 : 1.5,
                        ),
                        color: isSelected
                            ? Colors.cyan.withOpacity(0.1)
                            : const Color(0xFF1A1A1A),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onAnswerSelected(answer.id),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 24,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.cyan
                                          : const Color(0xFF404040),
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? Colors.cyan
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.black,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    answer.text,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.cyan
                                          : Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous button
                if (onPrevious != null)
                  OutlinedButton.icon(
                    onPressed: onPrevious,
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),

                // Next/Submit button
                ElevatedButton.icon(
                  onPressed: onNext,
                  icon: Icon(
                    isLastQuestion ? Icons.send : Icons.arrow_forward,
                    size: 20,
                  ),
                  label: Text(isLastQuestion ? 'Submit' : 'Next'),
                ),
              ],
            ),
          ],
        ),
    );
  }
}
