package io.flutter.plugin.editing;

import D2.r;
import D2.v;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.text.DynamicLayout;
import android.text.Editable;
import android.text.Layout;
import android.text.Selection;
import android.text.TextPaint;
import android.view.KeyEvent;
import android.view.inputmethod.BaseInputConnection;
import android.view.inputmethod.CursorAnchorInfo;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.ExtractedText;
import android.view.inputmethod.ExtractedTextRequest;
import android.view.inputmethod.InputContentInfo;
import android.view.inputmethod.InputMethodManager;
import io.flutter.embedding.engine.FlutterJNI;
import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.HashMap;
import y0.C0747k;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class c extends BaseInputConnection implements e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final r f4550a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final int f4551b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final v f4552c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final f f4553d;
    public final EditorInfo e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public ExtractedTextRequest f4554f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public boolean f4555g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public CursorAnchorInfo.Builder f4556h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final ExtractedText f4557i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final InputMethodManager f4558j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final DynamicLayout f4559k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final C0779j f4560l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final C0747k f4561m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f4562n;

    public c(r rVar, int i4, v vVar, C0747k c0747k, f fVar, EditorInfo editorInfo) {
        FlutterJNI flutterJNI = new FlutterJNI();
        super(rVar, true);
        this.f4555g = false;
        this.f4557i = new ExtractedText();
        this.f4562n = 0;
        this.f4550a = rVar;
        this.f4551b = i4;
        this.f4552c = vVar;
        this.f4553d = fVar;
        fVar.a(this);
        this.e = editorInfo;
        this.f4561m = c0747k;
        this.f4560l = new C0779j(flutterJNI, 25);
        this.f4559k = new DynamicLayout(fVar, new TextPaint(), com.google.android.gms.common.api.f.API_PRIORITY_OTHER, Layout.Alignment.ALIGN_NORMAL, 1.0f, 0.0f, false);
        this.f4558j = (InputMethodManager) rVar.getContext().getSystemService("input_method");
    }

    @Override // io.flutter.plugin.editing.e
    public final void a(boolean z4) {
        f fVar = this.f4553d;
        fVar.getClass();
        this.f4558j.updateSelection(this.f4550a, Selection.getSelectionStart(fVar), Selection.getSelectionEnd(fVar), BaseInputConnection.getComposingSpanStart(fVar), BaseInputConnection.getComposingSpanEnd(fVar));
        ExtractedTextRequest extractedTextRequest = this.f4554f;
        InputMethodManager inputMethodManager = this.f4558j;
        r rVar = this.f4550a;
        if (extractedTextRequest != null) {
            inputMethodManager.updateExtractedText(rVar, extractedTextRequest.token, c(extractedTextRequest));
        }
        if (this.f4555g) {
            inputMethodManager.updateCursorAnchorInfo(rVar, b());
        }
    }

    public final CursorAnchorInfo b() {
        CursorAnchorInfo.Builder builder = this.f4556h;
        if (builder == null) {
            this.f4556h = new CursorAnchorInfo.Builder();
        } else {
            builder.reset();
        }
        CursorAnchorInfo.Builder builder2 = this.f4556h;
        f fVar = this.f4553d;
        fVar.getClass();
        int selectionStart = Selection.getSelectionStart(fVar);
        fVar.getClass();
        builder2.setSelectionRange(selectionStart, Selection.getSelectionEnd(fVar));
        fVar.getClass();
        int composingSpanStart = BaseInputConnection.getComposingSpanStart(fVar);
        fVar.getClass();
        int composingSpanEnd = BaseInputConnection.getComposingSpanEnd(fVar);
        if (composingSpanStart < 0 || composingSpanEnd <= composingSpanStart) {
            this.f4556h.setComposingText(-1, "");
        } else {
            this.f4556h.setComposingText(composingSpanStart, fVar.toString().subSequence(composingSpanStart, composingSpanEnd));
        }
        return this.f4556h.build();
    }

    @Override // android.view.inputmethod.BaseInputConnection, android.view.inputmethod.InputConnection
    public final boolean beginBatchEdit() {
        this.f4553d.b();
        this.f4562n++;
        return super.beginBatchEdit();
    }

    public final ExtractedText c(ExtractedTextRequest extractedTextRequest) {
        ExtractedText extractedText = this.f4557i;
        extractedText.startOffset = 0;
        extractedText.partialStartOffset = -1;
        extractedText.partialEndOffset = -1;
        CharSequence string = this.f4553d;
        string.getClass();
        extractedText.selectionStart = Selection.getSelectionStart(string);
        string.getClass();
        extractedText.selectionEnd = Selection.getSelectionEnd(string);
        if (extractedTextRequest == null || (extractedTextRequest.flags & 1) == 0) {
            string = string.toString();
        }
        extractedText.text = string;
        return extractedText;
    }

    @Override // android.view.inputmethod.BaseInputConnection, android.view.inputmethod.InputConnection
    public final void closeConnection() {
        super.closeConnection();
        this.f4553d.e(this);
        while (this.f4562n > 0) {
            endBatchEdit();
            this.f4562n--;
        }
    }

    @Override // android.view.inputmethod.BaseInputConnection, android.view.inputmethod.InputConnection
    public final boolean commitContent(InputContentInfo inputContentInfo, int i4, Bundle bundle) {
        int i5;
        if (Build.VERSION.SDK_INT >= 25 && (i4 & 1) != 0) {
            try {
                inputContentInfo.requestPermission();
                if (inputContentInfo.getDescription().getMimeTypeCount() > 0) {
                    inputContentInfo.requestPermission();
                    Uri contentUri = inputContentInfo.getContentUri();
                    String mimeType = inputContentInfo.getDescription().getMimeType(0);
                    Context context = this.f4550a.getContext();
                    if (contentUri != null) {
                        try {
                            InputStream inputStreamOpenInputStream = context.getContentResolver().openInputStream(contentUri);
                            if (inputStreamOpenInputStream != null) {
                                ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                                byte[] bArr = new byte[65536];
                                while (true) {
                                    try {
                                        i5 = inputStreamOpenInputStream.read(bArr);
                                    } catch (IOException unused) {
                                        i5 = -1;
                                    }
                                    if (i5 == -1) {
                                        byte[] byteArray = byteArrayOutputStream.toByteArray();
                                        HashMap map = new HashMap();
                                        map.put("mimeType", mimeType);
                                        map.put("data", byteArray);
                                        map.put("uri", contentUri.toString());
                                        v vVar = this.f4552c;
                                        vVar.getClass();
                                        ((C0747k) vVar.f260b).O("TextInputClient.performAction", Arrays.asList(Integer.valueOf(this.f4551b), "TextInputAction.commitContent", map), null);
                                        inputContentInfo.releasePermission();
                                        return true;
                                    }
                                    byteArrayOutputStream.write(bArr, 0, i5);
                                }
                            }
                        } catch (FileNotFoundException unused2) {
                            inputContentInfo.releasePermission();
                            return false;
                        }
                    }
                    inputContentInfo.releasePermission();
                }
            } catch (Exception unused3) {
            }
        }
        return false;
    }

    /* JADX WARN: Code restructure failed: missing block: B:164:0x028b, code lost:
    
        r14 = r14 + r4;
     */
    /* JADX WARN: Removed duplicated region for block: B:180:0x02c7 A[ADDED_TO_REGION] */
    /* JADX WARN: Removed duplicated region for block: B:198:0x003f A[ADDED_TO_REGION, EDGE_INSN: B:198:0x003f->B:18:0x003f BREAK  A[LOOP:2: B:63:0x00fe->B:201:?], REMOVE, SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:208:0x01ad A[ADDED_TO_REGION, EDGE_INSN: B:208:0x01ad->B:108:0x01ad BREAK  A[LOOP:4: B:143:0x0232->B:211:?], REMOVE, SYNTHETIC] */
    /* JADX WARN: Removed duplicated region for block: B:62:0x00fc  */
    /* JADX WARN: Removed duplicated region for block: B:93:0x0177 A[ADDED_TO_REGION] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final boolean d(boolean r17, boolean r18) {
        /*
            Method dump skipped, instruction units count: 742
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: io.flutter.plugin.editing.c.d(boolean, boolean):boolean");
    }

    @Override // android.view.inputmethod.BaseInputConnection, android.view.inputmethod.InputConnection
    public final boolean deleteSurroundingText(int i4, int i5) {
        f fVar = this.f4553d;
        fVar.getClass();
        if (Selection.getSelectionStart(fVar) == -1) {
            return true;
        }
        return super.deleteSurroundingText(i4, i5);
    }

    public final boolean e(boolean z4, boolean z5) {
        f fVar = this.f4553d;
        int selectionStart = Selection.getSelectionStart(fVar);
        int selectionEnd = Selection.getSelectionEnd(fVar);
        boolean z6 = false;
        if (selectionStart < 0 || selectionEnd < 0) {
            return false;
        }
        if (selectionStart == selectionEnd && !z5) {
            z6 = true;
        }
        beginBatchEdit();
        DynamicLayout dynamicLayout = this.f4559k;
        if (z6) {
            if (z4) {
                Selection.moveUp(fVar, dynamicLayout);
            } else {
                Selection.moveDown(fVar, dynamicLayout);
            }
            int selectionStart2 = Selection.getSelectionStart(fVar);
            setSelection(selectionStart2, selectionStart2);
        } else {
            if (z4) {
                Selection.extendUp(fVar, dynamicLayout);
            } else {
                Selection.extendDown(fVar, dynamicLayout);
            }
            setSelection(Selection.getSelectionStart(fVar), Selection.getSelectionEnd(fVar));
        }
        endBatchEdit();
        return true;
    }

    @Override // android.view.inputmethod.BaseInputConnection, android.view.inputmethod.InputConnection
    public final boolean endBatchEdit() {
        boolean zEndBatchEdit = super.endBatchEdit();
        this.f4562n--;
        this.f4553d.c();
        return zEndBatchEdit;
    }

    @Override // android.view.inputmethod.BaseInputConnection
    public final Editable getEditable() {
        return this.f4553d;
    }

    @Override // android.view.inputmethod.BaseInputConnection, android.view.inputmethod.InputConnection
    public final ExtractedText getExtractedText(ExtractedTextRequest extractedTextRequest, int i4) {
        this.f4554f = (i4 & 1) != 0 ? extractedTextRequest : null;
        return c(extractedTextRequest);
    }

    @Override // android.view.inputmethod.BaseInputConnection, android.view.inputmethod.InputConnection
    public final boolean performContextMenuAction(int i4) {
        beginBatchEdit();
        boolean z4 = true;
        f fVar = this.f4553d;
        if (i4 == 16908319) {
            setSelection(0, fVar.length());
        } else {
            r rVar = this.f4550a;
            if (i4 == 16908320) {
                int selectionStart = Selection.getSelectionStart(fVar);
                int selectionEnd = Selection.getSelectionEnd(fVar);
                if (selectionStart != selectionEnd) {
                    int iMin = Math.min(selectionStart, selectionEnd);
                    int iMax = Math.max(selectionStart, selectionEnd);
                    ((ClipboardManager) rVar.getContext().getSystemService("clipboard")).setPrimaryClip(ClipData.newPlainText("text label?", fVar.subSequence(iMin, iMax)));
                    fVar.delete(iMin, iMax);
                    setSelection(iMin, iMin);
                }
            } else if (i4 == 16908321) {
                int selectionStart2 = Selection.getSelectionStart(fVar);
                int selectionEnd2 = Selection.getSelectionEnd(fVar);
                if (selectionStart2 != selectionEnd2) {
                    ((ClipboardManager) rVar.getContext().getSystemService("clipboard")).setPrimaryClip(ClipData.newPlainText("text label?", fVar.subSequence(Math.min(selectionStart2, selectionEnd2), Math.max(selectionStart2, selectionEnd2))));
                }
            } else if (i4 == 16908322) {
                ClipData primaryClip = ((ClipboardManager) rVar.getContext().getSystemService("clipboard")).getPrimaryClip();
                if (primaryClip != null) {
                    CharSequence charSequenceCoerceToText = primaryClip.getItemAt(0).coerceToText(rVar.getContext());
                    int iMax2 = Math.max(0, Selection.getSelectionStart(fVar));
                    int iMax3 = Math.max(0, Selection.getSelectionEnd(fVar));
                    int iMin2 = Math.min(iMax2, iMax3);
                    int iMax4 = Math.max(iMax2, iMax3);
                    if (iMin2 != iMax4) {
                        fVar.delete(iMin2, iMax4);
                    }
                    fVar.insert(iMin2, charSequenceCoerceToText);
                    int length = charSequenceCoerceToText.length() + iMin2;
                    setSelection(length, length);
                }
            } else {
                z4 = false;
            }
        }
        endBatchEdit();
        return z4;
    }

    @Override // android.view.inputmethod.BaseInputConnection, android.view.inputmethod.InputConnection
    public final boolean performEditorAction(int i4) {
        int i5 = this.f4551b;
        v vVar = this.f4552c;
        if (i4 == 0) {
            vVar.getClass();
            ((C0747k) vVar.f260b).O("TextInputClient.performAction", Arrays.asList(Integer.valueOf(i5), "TextInputAction.unspecified"), null);
            return true;
        }
        if (i4 == 1) {
            vVar.getClass();
            ((C0747k) vVar.f260b).O("TextInputClient.performAction", Arrays.asList(Integer.valueOf(i5), "TextInputAction.newline"), null);
            return true;
        }
        if (i4 == 2) {
            vVar.getClass();
            ((C0747k) vVar.f260b).O("TextInputClient.performAction", Arrays.asList(Integer.valueOf(i5), "TextInputAction.go"), null);
            return true;
        }
        if (i4 == 3) {
            vVar.getClass();
            ((C0747k) vVar.f260b).O("TextInputClient.performAction", Arrays.asList(Integer.valueOf(i5), "TextInputAction.search"), null);
            return true;
        }
        if (i4 == 4) {
            vVar.getClass();
            ((C0747k) vVar.f260b).O("TextInputClient.performAction", Arrays.asList(Integer.valueOf(i5), "TextInputAction.send"), null);
            return true;
        }
        if (i4 == 5) {
            vVar.getClass();
            ((C0747k) vVar.f260b).O("TextInputClient.performAction", Arrays.asList(Integer.valueOf(i5), "TextInputAction.next"), null);
            return true;
        }
        if (i4 != 7) {
            vVar.getClass();
            ((C0747k) vVar.f260b).O("TextInputClient.performAction", Arrays.asList(Integer.valueOf(i5), "TextInputAction.done"), null);
            return true;
        }
        vVar.getClass();
        ((C0747k) vVar.f260b).O("TextInputClient.performAction", Arrays.asList(Integer.valueOf(i5), "TextInputAction.previous"), null);
        return true;
    }

    @Override // android.view.inputmethod.BaseInputConnection, android.view.inputmethod.InputConnection
    public final boolean performPrivateCommand(String str, Bundle bundle) {
        v vVar = this.f4552c;
        vVar.getClass();
        HashMap map = new HashMap();
        map.put("action", str);
        if (bundle != null) {
            HashMap map2 = new HashMap();
            for (String str2 : bundle.keySet()) {
                Object obj = bundle.get(str2);
                if (obj instanceof byte[]) {
                    map2.put(str2, bundle.getByteArray(str2));
                } else if (obj instanceof Byte) {
                    map2.put(str2, Byte.valueOf(bundle.getByte(str2)));
                } else if (obj instanceof char[]) {
                    map2.put(str2, bundle.getCharArray(str2));
                } else if (obj instanceof Character) {
                    map2.put(str2, Character.valueOf(bundle.getChar(str2)));
                } else if (obj instanceof CharSequence[]) {
                    map2.put(str2, bundle.getCharSequenceArray(str2));
                } else if (obj instanceof CharSequence) {
                    map2.put(str2, bundle.getCharSequence(str2));
                } else if (obj instanceof float[]) {
                    map2.put(str2, bundle.getFloatArray(str2));
                } else if (obj instanceof Float) {
                    map2.put(str2, Float.valueOf(bundle.getFloat(str2)));
                }
            }
            map.put("data", map2);
        }
        ((C0747k) vVar.f260b).O("TextInputClient.performPrivateCommand", Arrays.asList(Integer.valueOf(this.f4551b), map), null);
        return true;
    }

    @Override // android.view.inputmethod.BaseInputConnection, android.view.inputmethod.InputConnection
    public final boolean requestCursorUpdates(int i4) {
        if ((i4 & 1) != 0) {
            this.f4558j.updateCursorAnchorInfo(this.f4550a, b());
        }
        this.f4555g = (i4 & 2) != 0;
        return true;
    }

    @Override // android.view.inputmethod.BaseInputConnection, android.view.inputmethod.InputConnection
    public final boolean sendKeyEvent(KeyEvent keyEvent) {
        return this.f4561m.M(keyEvent);
    }

    @Override // android.view.inputmethod.BaseInputConnection, android.view.inputmethod.InputConnection
    public final boolean setComposingText(CharSequence charSequence, int i4) {
        beginBatchEdit();
        boolean zCommitText = charSequence.length() == 0 ? super.commitText(charSequence, i4) : super.setComposingText(charSequence, i4);
        endBatchEdit();
        return zCommitText;
    }

    @Override // android.view.inputmethod.BaseInputConnection, android.view.inputmethod.InputConnection
    public final boolean setSelection(int i4, int i5) {
        beginBatchEdit();
        boolean selection = super.setSelection(i4, i5);
        endBatchEdit();
        return selection;
    }
}
