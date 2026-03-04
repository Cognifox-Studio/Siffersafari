import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/input_validators.dart';
import '../../domain/services/parent_pin_service.dart';
import '../../core/providers/parent_pin_service_provider.dart';

enum _RecoveryStep {
  questionInput,
  backupCodeSelection,
  newPinInput,
  success,
}

class PinRecoveryScreen extends ConsumerStatefulWidget {
  const PinRecoveryScreen({super.key, required this.onRecoveryComplete});

  final VoidCallback onRecoveryComplete;

  @override
  ConsumerState<PinRecoveryScreen> createState() => _PinRecoveryScreenState();
}

class _PinRecoveryScreenState extends ConsumerState<PinRecoveryScreen> {
  late ParentPinService _pinService;
  _RecoveryStep _currentStep = _RecoveryStep.questionInput;

  String? _securityQuestion;
  final _answerController = TextEditingController();
  String? _selectedBackupCode;
  final _newPin1Controller = TextEditingController();
  final _newPin2Controller = TextEditingController();
  bool _showPin = false;

  String? _errorMessage;
  bool _isLoading = false;
  List<String> _remainingCodes = [];

  @override
  void initState() {
    super.initState();
    _pinService = ref.read(parentPinServiceProvider);
    _securityQuestion = _pinService.getSecurityQuestion();

    if (_securityQuestion == null) {
      _showErrorDialog('Ingen PIN-recovery konfigurerad för denna profil.');
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _newPin1Controller.dispose();
    _newPin2Controller.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fel'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (message.contains('Ingen PIN-recovery')) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifySecurityAnswer() async {
    // Validate security answer
    final answerError = InputValidators.validateSecurityAnswer(_answerController.text);
    if (answerError != null) {
      setState(() => _errorMessage = answerError);
      return;
    }

    final answer = InputValidators.sanitizeSecurityAnswer(_answerController.text);

    setState(() => _isLoading = true);
    try {
      final (isCorrect, codeCounts) =
          await _pinService.verifySecurityAnswer(answer);

      if (isCorrect) {
        // Get the hashed codes to display (we'll show them as-is from storage for now)
        // In a real app, you'd display the plaintext codes from setupPinRecovery
        setState(() {
          _currentStep = _RecoveryStep.backupCodeSelection;
          _errorMessage = null;
        });
      } else {
        setState(
          () => _errorMessage = 'Felaktigt svar. Försök igen.',
        );
      }
    } catch (e) {
      setState(
        () => _errorMessage = 'Ett fel inträffade: $e',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyBackupCodeAndResetPin() async {
    if (_selectedBackupCode == null || _selectedBackupCode!.isEmpty) {
      setState(() => _errorMessage = 'Välj en backup-kod');
      return;
    }

    // Validate new PINs
    final pin1Error = InputValidators.validatePin(_newPin1Controller.text);
    if (pin1Error != null) {
      setState(() => _errorMessage = pin1Error);
      return;
    }

    final pin2Error = InputValidators.validatePin(_newPin2Controller.text);
    if (pin2Error != null) {
      setState(() => _errorMessage = pin2Error);
      return;
    }

    final newPin1 = InputValidators.sanitizePin(_newPin1Controller.text.trim());
    final newPin2 = InputValidators.sanitizePin(_newPin2Controller.text.trim());

    if (newPin1 != newPin2) {
      setState(() => _errorMessage = 'PIN:erna matchar inte');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final codeValid =
          await _pinService.verifyAndUseBackupCode(_selectedBackupCode!);

      if (!codeValid) {
        setState(
          () => _errorMessage =
              'Backup-koden är ogiltig eller redan använd.',
        );
        return;
      }

      // Code is valid, now set the new PIN
      await _pinService.setPin(newPin1);

      // Regenerate new backup codes for future recovery
      final newCodes = await _pinService.regenerateBackupCodes();

      // Show success with new backup codes
      setState(() {
        _currentStep = _RecoveryStep.success;
        _remainingCodes = newCodes;
        _errorMessage = null;
      });
    } catch (e) {
      setState(
        () => _errorMessage = 'Ett fel inträffade: $e',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Återställ PIN'),
        elevation: 0,
      ),
      body: _securityQuestion == null
          ? const Center(child: Text('Ingen recovery-konfiguration'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildCurrentStep(),
            ),
    );
  }

  Widget _buildCurrentStep() {
    return switch (_currentStep) {
      _RecoveryStep.questionInput => _buildQuestionStep(),
      _RecoveryStep.backupCodeSelection => _buildCodeSelectionStep(),
      _RecoveryStep.newPinInput => _buildNewPinStep(),
      _RecoveryStep.success => _buildSuccessStep(),
    };
  }

  Widget _buildQuestionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Säkerhetsfråga',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Text(
            _securityQuestion!,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _answerController,
          decoration: InputDecoration(
            labelText: 'Svar',
            hintText: 'Ange svar på säkerhetsfrågan',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: _errorMessage,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifySecurityAnswer,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Verifiera svar'),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Välj en backup-kod',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ange en av dine tidigare sparade backup-koder.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: TextEditingController(text: _selectedBackupCode),
          onChanged: (value) {
            setState(() {
              _selectedBackupCode = value.trim().toUpperCase();
              _errorMessage = null;
            });
          },
          decoration: InputDecoration(
            labelText: 'Backup-kod',
            hintText: 'T.ex. ABC12345',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: _errorMessage,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = _RecoveryStep.questionInput;
                    _errorMessage = null;
                  });
                },
                child: const Text('Tillbaka'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = _RecoveryStep.newPinInput;
                    _errorMessage = null;
                  });
                },
                child: const Text('Nästa'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewPinStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ny PIN',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _newPin1Controller,
          obscureText: !_showPin,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Ny PIN',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: IconButton(
              icon: Icon(_showPin ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() => _showPin = !_showPin);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _newPin2Controller,
          obscureText: !_showPin,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Bekräfta PIN',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: IconButton(
              icon: Icon(_showPin ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() => _showPin = !_showPin);
              },
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = _RecoveryStep.backupCodeSelection;
                    _errorMessage = null;
                  });
                },
                child: const Text('Tillbaka'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyBackupCodeAndResetPin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Återställ PIN'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Icon(
          Icons.check_circle,
          color: Colors.green.shade600,
          size: 64,
        ),
        const SizedBox(height: 24),
        const Text(
          'PIN återställd!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Din PIN har återställts. Nya backup-koder har genererats.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        const Text(
          'Spara dina nya backup-koder på en säker plats:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _remainingCodes
                .map(
                  (code) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SelectableText(
                          code,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              widget.onRecoveryComplete();
              Navigator.of(context).pop();
            },
            child: const Text('Stäng'),
          ),
        ),
      ],
    );
  }
}
