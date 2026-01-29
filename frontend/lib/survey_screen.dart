import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'question_page.dart';
import 'loading_screen.dart';
import 'results_screen.dart';

// API endpoint - Django backend
// Default to production URL, can be overridden with --dart-define=API_BASE_URL=...
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://your-app-name.net/api/counter/',
);

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  List<QuestionData> _questions = [];
  Map<int, int> _selectedAnswers = {}; // question_id -> answer_id
  bool _isLoading = true;
  String? _errorMessage;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${apiBaseUrl}survey/questions/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _questions = (data['questions'] as List)
              .map((q) => QuestionData.fromJson(q))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load questions. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error connecting to backend: $e';
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(int questionId, int answerId) {
    setState(() {
      _selectedAnswers[questionId] = answerId;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  bool _canGoNext() {
    if (_questions.isEmpty) return false;
    final currentQuestion = _questions[_currentQuestionIndex];
    return _selectedAnswers.containsKey(currentQuestion.id);
  }

  bool _isLastQuestion() {
    return _currentQuestionIndex == _questions.length - 1;
  }

  Future<void> _submitSurvey() async {
    // Navigate to loading screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          onLoad: () => _submitSurveyData(),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _submitSurveyData() async {
    // Prepare response data
    final responses = _selectedAnswers.entries.map((entry) {
      return {
        'question_id': entry.key,
        'answer_id': entry.value,
      };
    }).toList();

    final response = await http.post(
      Uri.parse('${apiBaseUrl}survey/submit/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'responses': responses,
        'session_id': '', // Optional
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['results'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to submit survey: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              const Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Survey'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.cyan.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Loading survey...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              const Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Survey'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _loadQuestions,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              const Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Survey'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: const Center(
            child: Text(
              'No questions available',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final selectedAnswerId = _selectedAnswers[currentQuestion.id];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            const Color(0xFF0A0A0A),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Question ${_currentQuestionIndex + 1} of ${_questions.length}'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: QuestionPage(
          question: currentQuestion,
          selectedAnswerId: selectedAnswerId,
          onAnswerSelected: (answerId) => _selectAnswer(currentQuestion.id, answerId),
          onNext: _canGoNext() ? (_isLastQuestion() ? _submitSurvey : _nextQuestion) : null,
          onPrevious: _currentQuestionIndex > 0 ? _previousQuestion : null,
          isLastQuestion: _isLastQuestion(),
        ),
      ),
    );
  }
}

class QuestionData {
  final int id;
  final String text;
  final int order;
  final List<AnswerData> answers;

  QuestionData({
    required this.id,
    required this.text,
    required this.order,
    required this.answers,
  });

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      id: json['id'],
      text: json['text'],
      order: json['order'],
      answers: (json['answers'] as List)
          .map((a) => AnswerData.fromJson(a))
          .toList(),
    );
  }
}

class AnswerData {
  final int id;
  final String text;
  final String value;
  final int order;

  AnswerData({
    required this.id,
    required this.text,
    required this.value,
    required this.order,
  });

  factory AnswerData.fromJson(Map<String, dynamic> json) {
    return AnswerData(
      id: json['id'],
      text: json['text'],
      value: json['value'],
      order: json['order'],
    );
  }
}
