package io.flutter.plugin.editing;

import N2.p;
import android.text.Selection;
import android.text.SpannableStringBuilder;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.BaseInputConnection;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class f extends SpannableStringBuilder {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f4564a = 0;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f4565b = 0;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final ArrayList f4566c = new ArrayList();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final ArrayList f4567d = new ArrayList();
    public final ArrayList e = new ArrayList();

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public String f4568f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public String f4569m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f4570n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public int f4571o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public int f4572p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public int f4573q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final d f4574r;

    public f(p pVar, View view) {
        this.f4574r = new d(view, this);
        if (pVar != null) {
            f(pVar);
        }
    }

    public final void a(e eVar) {
        if (this.f4565b > 0) {
            Log.e("ListenableEditingState", "adding a listener " + eVar.toString() + " in a listener callback");
        }
        if (this.f4564a <= 0) {
            this.f4566c.add(eVar);
        } else {
            Log.w("ListenableEditingState", "a listener was added to EditingState while a batch edit was in progress");
            this.f4567d.add(eVar);
        }
    }

    public final void b() {
        this.f4564a++;
        if (this.f4565b > 0) {
            Log.e("ListenableEditingState", "editing state should not be changed in a listener callback");
        }
        if (this.f4564a != 1 || this.f4566c.isEmpty()) {
            return;
        }
        this.f4569m = toString();
        this.f4570n = Selection.getSelectionStart(this);
        this.f4571o = Selection.getSelectionEnd(this);
        this.f4572p = BaseInputConnection.getComposingSpanStart(this);
        this.f4573q = BaseInputConnection.getComposingSpanEnd(this);
    }

    public final void c() {
        int i4 = this.f4564a;
        if (i4 == 0) {
            Log.e("ListenableEditingState", "endBatchEdit called without a matching beginBatchEdit");
            return;
        }
        ArrayList arrayList = this.f4566c;
        ArrayList<e> arrayList2 = this.f4567d;
        if (i4 == 1) {
            for (e eVar : arrayList2) {
                this.f4565b++;
                eVar.a(true);
                this.f4565b--;
            }
            if (!arrayList.isEmpty()) {
                arrayList.size();
                d(!toString().equals(this.f4569m), (this.f4570n == Selection.getSelectionStart(this) && this.f4571o == Selection.getSelectionEnd(this)) ? false : true, (this.f4572p == BaseInputConnection.getComposingSpanStart(this) && this.f4573q == BaseInputConnection.getComposingSpanEnd(this)) ? false : true);
            }
        }
        arrayList.addAll(arrayList2);
        arrayList2.clear();
        this.f4564a--;
    }

    public final void d(boolean z4, boolean z5, boolean z6) {
        if (z4 || z5 || z6) {
            for (e eVar : this.f4566c) {
                this.f4565b++;
                eVar.a(z4);
                this.f4565b--;
            }
        }
    }

    public final void e(e eVar) {
        if (this.f4565b > 0) {
            Log.e("ListenableEditingState", "removing a listener " + eVar.toString() + " in a listener callback");
        }
        this.f4566c.remove(eVar);
        if (this.f4564a > 0) {
            this.f4567d.remove(eVar);
        }
    }

    public final void f(p pVar) {
        int i4;
        b();
        replace(0, length(), (CharSequence) pVar.f1194a);
        int i5 = pVar.f1195b;
        if (i5 >= 0) {
            Selection.setSelection(this, i5, pVar.f1196c);
        } else {
            Selection.removeSelection(this);
        }
        int i6 = pVar.f1197d;
        if (i6 < 0 || i6 >= (i4 = pVar.e)) {
            BaseInputConnection.removeComposingSpans(this);
        } else {
            this.f4574r.setComposingRegion(i6, i4);
        }
        this.e.clear();
        c();
    }

    @Override // android.text.SpannableStringBuilder, android.text.Spannable
    public final void setSpan(Object obj, int i4, int i5, int i6) {
        super.setSpan(obj, i4, i5, i6);
        ArrayList arrayList = this.e;
        String string = toString();
        int selectionStart = Selection.getSelectionStart(this);
        int selectionEnd = Selection.getSelectionEnd(this);
        int composingSpanStart = BaseInputConnection.getComposingSpanStart(this);
        int composingSpanEnd = BaseInputConnection.getComposingSpanEnd(this);
        h hVar = new h();
        hVar.e = selectionStart;
        hVar.f4583f = selectionEnd;
        hVar.f4584g = composingSpanStart;
        hVar.f4585h = composingSpanEnd;
        hVar.f4579a = string;
        hVar.f4580b = "";
        hVar.f4581c = -1;
        hVar.f4582d = -1;
        arrayList.add(hVar);
    }

    @Override // android.text.SpannableStringBuilder, java.lang.CharSequence
    public final String toString() {
        String str = this.f4568f;
        if (str != null) {
            return str;
        }
        String string = super.toString();
        this.f4568f = string;
        return string;
    }

    @Override // android.text.SpannableStringBuilder, android.text.Editable
    public final SpannableStringBuilder replace(int i4, int i5, CharSequence charSequence, int i6, int i7) {
        if (this.f4565b > 0) {
            Log.e("ListenableEditingState", "editing state should not be changed in a listener callback");
        }
        String string = toString();
        int i8 = i5 - i4;
        boolean z4 = i8 != i7 - i6;
        for (int i9 = 0; i9 < i8 && !z4; i9++) {
            z4 |= charAt(i4 + i9) != charSequence.charAt(i6 + i9);
        }
        if (z4) {
            this.f4568f = null;
        }
        int selectionStart = Selection.getSelectionStart(this);
        int selectionEnd = Selection.getSelectionEnd(this);
        int composingSpanStart = BaseInputConnection.getComposingSpanStart(this);
        int composingSpanEnd = BaseInputConnection.getComposingSpanEnd(this);
        SpannableStringBuilder spannableStringBuilderReplace = super.replace(i4, i5, charSequence, i6, i7);
        ArrayList arrayList = this.e;
        int selectionStart2 = Selection.getSelectionStart(this);
        int selectionEnd2 = Selection.getSelectionEnd(this);
        int composingSpanStart2 = BaseInputConnection.getComposingSpanStart(this);
        int composingSpanEnd2 = BaseInputConnection.getComposingSpanEnd(this);
        h hVar = new h();
        hVar.e = selectionStart2;
        hVar.f4583f = selectionEnd2;
        hVar.f4584g = composingSpanStart2;
        hVar.f4585h = composingSpanEnd2;
        String string2 = charSequence.toString();
        hVar.f4579a = string;
        hVar.f4580b = string2;
        hVar.f4581c = i4;
        hVar.f4582d = i5;
        arrayList.add(hVar);
        if (this.f4564a > 0) {
            return spannableStringBuilderReplace;
        }
        d(z4, (Selection.getSelectionStart(this) == selectionStart && Selection.getSelectionEnd(this) == selectionEnd) ? false : true, (BaseInputConnection.getComposingSpanStart(this) == composingSpanStart && BaseInputConnection.getComposingSpanEnd(this) == composingSpanEnd) ? false : true);
        return spannableStringBuilderReplace;
    }
}
