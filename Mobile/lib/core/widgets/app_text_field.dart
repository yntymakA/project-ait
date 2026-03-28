import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixWidget,
    this.focusNode,
  });

  /// Password variant — auto-manages show/hide toggle
  const AppTextField.password({
    super.key,
    this.label = 'Password',
    this.hint = '••••••••',
    this.helperText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
  })  : obscureText = true,
        keyboardType = TextInputType.visiblePassword,
        textInputAction = TextInputAction.done,
        maxLines = 1,
        maxLength = null,
        prefixIcon = Icons.lock_outline,
        suffixWidget = null;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscure,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: _obscure ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: AppSpacing.iconMd, color: AppColors.grey400)
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: AppSpacing.iconMd,
                  color: AppColors.grey400,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.suffixWidget,
        counterText: '',
      ),
    );
  }
}
