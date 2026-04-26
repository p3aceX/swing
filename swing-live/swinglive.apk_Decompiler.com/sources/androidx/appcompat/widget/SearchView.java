package androidx.appcompat.widget;

import A.C;
import A3.f;
import android.app.PendingIntent;
import android.app.SearchableInfo;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.content.res.TypedArray;
import android.database.Cursor;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Parcelable;
import android.text.Editable;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.text.style.ImageSpan;
import android.util.AttributeSet;
import android.util.Log;
import android.util.TypedValue;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;
import android.widget.AutoCompleteTextView;
import android.widget.ImageView;
import com.swing.live.R;
import e1.AbstractC0367g;
import f.AbstractC0398a;
import i.InterfaceC0416a;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.WeakHashMap;
import k.AbstractC0478F;
import k.AbstractC0496m;
import k.C0479G;
import k.T;
import k.U;
import k.V;
import k.W;
import k.X;
import k.Y;
import k.Z;
import k.a0;
import k.b0;
import k.c0;
import k.d0;
import k.f0;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public class SearchView extends AbstractC0478F implements InterfaceC0416a {

    /* JADX INFO: renamed from: m0, reason: collision with root package name */
    public static final f f2731m0;

    /* JADX INFO: renamed from: A, reason: collision with root package name */
    public final ImageView f2732A;

    /* JADX INFO: renamed from: B, reason: collision with root package name */
    public final ImageView f2733B;

    /* JADX INFO: renamed from: C, reason: collision with root package name */
    public final ImageView f2734C;

    /* JADX INFO: renamed from: D, reason: collision with root package name */
    public final View f2735D;

    /* JADX INFO: renamed from: E, reason: collision with root package name */
    public d0 f2736E;

    /* JADX INFO: renamed from: F, reason: collision with root package name */
    public final Rect f2737F;

    /* JADX INFO: renamed from: G, reason: collision with root package name */
    public final Rect f2738G;

    /* JADX INFO: renamed from: H, reason: collision with root package name */
    public final int[] f2739H;

    /* JADX INFO: renamed from: I, reason: collision with root package name */
    public final int[] f2740I;
    public final ImageView J;

    /* JADX INFO: renamed from: K, reason: collision with root package name */
    public final Drawable f2741K;

    /* JADX INFO: renamed from: L, reason: collision with root package name */
    public final int f2742L;

    /* JADX INFO: renamed from: M, reason: collision with root package name */
    public final int f2743M;

    /* JADX INFO: renamed from: N, reason: collision with root package name */
    public final Intent f2744N;

    /* JADX INFO: renamed from: O, reason: collision with root package name */
    public final Intent f2745O;

    /* JADX INFO: renamed from: P, reason: collision with root package name */
    public final CharSequence f2746P;

    /* JADX INFO: renamed from: Q, reason: collision with root package name */
    public View.OnFocusChangeListener f2747Q;

    /* JADX INFO: renamed from: R, reason: collision with root package name */
    public View.OnClickListener f2748R;

    /* JADX INFO: renamed from: S, reason: collision with root package name */
    public boolean f2749S;

    /* JADX INFO: renamed from: T, reason: collision with root package name */
    public boolean f2750T;

    /* JADX INFO: renamed from: U, reason: collision with root package name */
    public G.b f2751U;

    /* JADX INFO: renamed from: V, reason: collision with root package name */
    public boolean f2752V;

    /* JADX INFO: renamed from: W, reason: collision with root package name */
    public CharSequence f2753W;

    /* JADX INFO: renamed from: a0, reason: collision with root package name */
    public boolean f2754a0;

    /* JADX INFO: renamed from: b0, reason: collision with root package name */
    public boolean f2755b0;

    /* JADX INFO: renamed from: c0, reason: collision with root package name */
    public int f2756c0;

    /* JADX INFO: renamed from: d0, reason: collision with root package name */
    public boolean f2757d0;

    /* JADX INFO: renamed from: e0, reason: collision with root package name */
    public CharSequence f2758e0;

    /* JADX INFO: renamed from: f0, reason: collision with root package name */
    public boolean f2759f0;

    /* JADX INFO: renamed from: g0, reason: collision with root package name */
    public int f2760g0;
    public SearchableInfo h0;

    /* JADX INFO: renamed from: i0, reason: collision with root package name */
    public Bundle f2761i0;

    /* JADX INFO: renamed from: j0, reason: collision with root package name */
    public final U f2762j0;

    /* JADX INFO: renamed from: k0, reason: collision with root package name */
    public final U f2763k0;

    /* JADX INFO: renamed from: l0, reason: collision with root package name */
    public final WeakHashMap f2764l0;
    public final SearchAutoComplete v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public final View f2765w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public final View f2766x;

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public final View f2767y;

    /* JADX INFO: renamed from: z, reason: collision with root package name */
    public final ImageView f2768z;

    public static class SearchAutoComplete extends AbstractC0496m {

        /* JADX INFO: renamed from: d, reason: collision with root package name */
        public int f2769d;
        public SearchView e;

        /* JADX INFO: renamed from: f, reason: collision with root package name */
        public boolean f2770f;

        /* JADX INFO: renamed from: m, reason: collision with root package name */
        public final c f2771m;

        public SearchAutoComplete(Context context, AttributeSet attributeSet) {
            super(context, attributeSet);
            this.f2771m = new c(this);
            this.f2769d = getThreshold();
        }

        private int getSearchViewTextMinWidthDp() {
            Configuration configuration = getResources().getConfiguration();
            int i4 = configuration.screenWidthDp;
            int i5 = configuration.screenHeightDp;
            if (i4 >= 960 && i5 >= 720 && configuration.orientation == 2) {
                return 256;
            }
            if (i4 < 600) {
                return (i4 < 640 || i5 < 480) ? 160 : 192;
            }
            return 192;
        }

        @Override // android.widget.AutoCompleteTextView
        public final boolean enoughToFilter() {
            return this.f2769d <= 0 || super.enoughToFilter();
        }

        @Override // k.AbstractC0496m, android.widget.TextView, android.view.View
        public final InputConnection onCreateInputConnection(EditorInfo editorInfo) {
            InputConnection inputConnectionOnCreateInputConnection = super.onCreateInputConnection(editorInfo);
            if (this.f2770f) {
                c cVar = this.f2771m;
                removeCallbacks(cVar);
                post(cVar);
            }
            return inputConnectionOnCreateInputConnection;
        }

        @Override // android.view.View
        public final void onFinishInflate() {
            super.onFinishInflate();
            setMinWidth((int) TypedValue.applyDimension(1, getSearchViewTextMinWidthDp(), getResources().getDisplayMetrics()));
        }

        @Override // android.widget.AutoCompleteTextView, android.widget.TextView, android.view.View
        public final void onFocusChanged(boolean z4, int i4, Rect rect) {
            super.onFocusChanged(z4, i4, rect);
            SearchView searchView = this.e;
            searchView.u(searchView.f2750T);
            searchView.post(searchView.f2762j0);
            if (searchView.v.hasFocus()) {
                searchView.j();
            }
        }

        @Override // android.widget.AutoCompleteTextView, android.widget.TextView, android.view.View
        public final boolean onKeyPreIme(int i4, KeyEvent keyEvent) {
            if (i4 == 4) {
                if (keyEvent.getAction() == 0 && keyEvent.getRepeatCount() == 0) {
                    KeyEvent.DispatcherState keyDispatcherState = getKeyDispatcherState();
                    if (keyDispatcherState != null) {
                        keyDispatcherState.startTracking(keyEvent, this);
                    }
                    return true;
                }
                if (keyEvent.getAction() == 1) {
                    KeyEvent.DispatcherState keyDispatcherState2 = getKeyDispatcherState();
                    if (keyDispatcherState2 != null) {
                        keyDispatcherState2.handleUpEvent(keyEvent);
                    }
                    if (keyEvent.isTracking() && !keyEvent.isCanceled()) {
                        this.e.clearFocus();
                        setImeVisibility(false);
                        return true;
                    }
                }
            }
            return super.onKeyPreIme(i4, keyEvent);
        }

        @Override // android.widget.AutoCompleteTextView, android.widget.TextView, android.view.View
        public final void onWindowFocusChanged(boolean z4) {
            Method method;
            super.onWindowFocusChanged(z4);
            if (z4 && this.e.hasFocus() && getVisibility() == 0) {
                this.f2770f = true;
                Context context = getContext();
                f fVar = SearchView.f2731m0;
                if (context.getResources().getConfiguration().orientation != 2 || (method = SearchView.f2731m0.f89c) == null) {
                    return;
                }
                try {
                    method.invoke(this, Boolean.TRUE);
                } catch (Exception unused) {
                }
            }
        }

        @Override // android.widget.AutoCompleteTextView
        public final void performCompletion() {
        }

        @Override // android.widget.AutoCompleteTextView
        public final void replaceText(CharSequence charSequence) {
        }

        public void setImeVisibility(boolean z4) {
            InputMethodManager inputMethodManager = (InputMethodManager) getContext().getSystemService("input_method");
            c cVar = this.f2771m;
            if (!z4) {
                this.f2770f = false;
                removeCallbacks(cVar);
                inputMethodManager.hideSoftInputFromWindow(getWindowToken(), 0);
            } else {
                if (!inputMethodManager.isActive(this)) {
                    this.f2770f = true;
                    return;
                }
                this.f2770f = false;
                removeCallbacks(cVar);
                inputMethodManager.showSoftInput(this, 0);
            }
        }

        public void setSearchView(SearchView searchView) {
            this.e = searchView;
        }

        @Override // android.widget.AutoCompleteTextView
        public void setThreshold(int i4) {
            super.setThreshold(i4);
            this.f2769d = i4;
        }
    }

    static {
        f fVar = new f();
        try {
            Method declaredMethod = AutoCompleteTextView.class.getDeclaredMethod("doBeforeTextChanged", new Class[0]);
            fVar.f87a = declaredMethod;
            declaredMethod.setAccessible(true);
        } catch (NoSuchMethodException unused) {
        }
        try {
            Method declaredMethod2 = AutoCompleteTextView.class.getDeclaredMethod("doAfterTextChanged", new Class[0]);
            fVar.f88b = declaredMethod2;
            declaredMethod2.setAccessible(true);
        } catch (NoSuchMethodException unused2) {
        }
        try {
            Method method = AutoCompleteTextView.class.getMethod("ensureImeVisible", Boolean.TYPE);
            fVar.f89c = method;
            method.setAccessible(true);
        } catch (NoSuchMethodException unused3) {
        }
        f2731m0 = fVar;
    }

    public SearchView(Context context) {
        this(context, null);
    }

    private int getPreferredHeight() {
        return getContext().getResources().getDimensionPixelSize(R.dimen.abc_search_view_preferred_height);
    }

    private int getPreferredWidth() {
        return getContext().getResources().getDimensionPixelSize(R.dimen.abc_search_view_preferred_width);
    }

    private void setQuery(CharSequence charSequence) {
        SearchAutoComplete searchAutoComplete = this.v;
        searchAutoComplete.setText(charSequence);
        searchAutoComplete.setSelection(TextUtils.isEmpty(charSequence) ? 0 : charSequence.length());
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void clearFocus() {
        this.f2755b0 = true;
        super.clearFocus();
        SearchAutoComplete searchAutoComplete = this.v;
        searchAutoComplete.clearFocus();
        searchAutoComplete.setImeVisibility(false);
        this.f2755b0 = false;
    }

    public int getImeOptions() {
        return this.v.getImeOptions();
    }

    public int getInputType() {
        return this.v.getInputType();
    }

    public int getMaxWidth() {
        return this.f2756c0;
    }

    public CharSequence getQuery() {
        return this.v.getText();
    }

    public CharSequence getQueryHint() {
        CharSequence charSequence = this.f2753W;
        if (charSequence != null) {
            return charSequence;
        }
        SearchableInfo searchableInfo = this.h0;
        return (searchableInfo == null || searchableInfo.getHintId() == 0) ? this.f2746P : getContext().getText(this.h0.getHintId());
    }

    public int getSuggestionCommitIconResId() {
        return this.f2743M;
    }

    public int getSuggestionRowLayout() {
        return this.f2742L;
    }

    public G.b getSuggestionsAdapter() {
        return this.f2751U;
    }

    public final Intent h(Uri uri, String str, String str2, String str3) {
        Intent intent = new Intent(str);
        intent.addFlags(268435456);
        if (uri != null) {
            intent.setData(uri);
        }
        intent.putExtra("user_query", this.f2758e0);
        if (str3 != null) {
            intent.putExtra("query", str3);
        }
        if (str2 != null) {
            intent.putExtra("intent_extra_data_key", str2);
        }
        Bundle bundle = this.f2761i0;
        if (bundle != null) {
            intent.putExtra("app_data", bundle);
        }
        intent.setComponent(this.h0.getSearchActivity());
        return intent;
    }

    public final Intent i(Intent intent, SearchableInfo searchableInfo) {
        ComponentName searchActivity = searchableInfo.getSearchActivity();
        Intent intent2 = new Intent("android.intent.action.SEARCH");
        intent2.setComponent(searchActivity);
        PendingIntent activity = PendingIntent.getActivity(getContext(), 0, intent2, 1073741824);
        Bundle bundle = new Bundle();
        Bundle bundle2 = this.f2761i0;
        if (bundle2 != null) {
            bundle.putParcelable("app_data", bundle2);
        }
        Intent intent3 = new Intent(intent);
        Resources resources = getResources();
        String string = searchableInfo.getVoiceLanguageModeId() != 0 ? resources.getString(searchableInfo.getVoiceLanguageModeId()) : "free_form";
        String string2 = searchableInfo.getVoicePromptTextId() != 0 ? resources.getString(searchableInfo.getVoicePromptTextId()) : null;
        String string3 = searchableInfo.getVoiceLanguageId() != 0 ? resources.getString(searchableInfo.getVoiceLanguageId()) : null;
        int voiceMaxResults = searchableInfo.getVoiceMaxResults() != 0 ? searchableInfo.getVoiceMaxResults() : 1;
        intent3.putExtra("android.speech.extra.LANGUAGE_MODEL", string);
        intent3.putExtra("android.speech.extra.PROMPT", string2);
        intent3.putExtra("android.speech.extra.LANGUAGE", string3);
        intent3.putExtra("android.speech.extra.MAX_RESULTS", voiceMaxResults);
        intent3.putExtra("calling_package", searchActivity != null ? searchActivity.flattenToShortString() : null);
        intent3.putExtra("android.speech.extra.RESULTS_PENDINGINTENT", activity);
        intent3.putExtra("android.speech.extra.RESULTS_PENDINGINTENT_BUNDLE", bundle);
        return intent3;
    }

    public final void j() {
        int i4 = Build.VERSION.SDK_INT;
        SearchAutoComplete searchAutoComplete = this.v;
        if (i4 >= 29) {
            searchAutoComplete.refreshAutoCompleteResults();
            return;
        }
        f fVar = f2731m0;
        Method method = fVar.f87a;
        if (method != null) {
            try {
                method.invoke(searchAutoComplete, new Object[0]);
            } catch (Exception unused) {
            }
        }
        Method method2 = fVar.f88b;
        if (method2 != null) {
            try {
                method2.invoke(searchAutoComplete, new Object[0]);
            } catch (Exception unused2) {
            }
        }
    }

    public final void k() {
        SearchAutoComplete searchAutoComplete = this.v;
        if (!TextUtils.isEmpty(searchAutoComplete.getText())) {
            searchAutoComplete.setText("");
            searchAutoComplete.requestFocus();
            searchAutoComplete.setImeVisibility(true);
        } else if (this.f2749S) {
            clearFocus();
            u(true);
        }
    }

    public final void l(int i4) {
        int position;
        String strH;
        Cursor cursor = this.f2751U.f478c;
        if (cursor != null && cursor.moveToPosition(i4)) {
            Intent intentH = null;
            try {
                int i5 = f0.f5353E;
                String strH2 = f0.h(cursor, cursor.getColumnIndex("suggest_intent_action"));
                if (strH2 == null) {
                    strH2 = this.h0.getSuggestIntentAction();
                }
                if (strH2 == null) {
                    strH2 = "android.intent.action.SEARCH";
                }
                String strH3 = f0.h(cursor, cursor.getColumnIndex("suggest_intent_data"));
                if (strH3 == null) {
                    strH3 = this.h0.getSuggestIntentData();
                }
                if (strH3 != null && (strH = f0.h(cursor, cursor.getColumnIndex("suggest_intent_data_id"))) != null) {
                    strH3 = strH3 + "/" + Uri.encode(strH);
                }
                intentH = h(strH3 == null ? null : Uri.parse(strH3), strH2, f0.h(cursor, cursor.getColumnIndex("suggest_intent_extra_data")), f0.h(cursor, cursor.getColumnIndex("suggest_intent_query")));
            } catch (RuntimeException e) {
                try {
                    position = cursor.getPosition();
                } catch (RuntimeException unused) {
                    position = -1;
                }
                Log.w("SearchView", "Search suggestions cursor at row " + position + " returned exception.", e);
            }
            if (intentH != null) {
                try {
                    getContext().startActivity(intentH);
                } catch (RuntimeException e4) {
                    Log.e("SearchView", "Failed launch activity: " + intentH, e4);
                }
            }
        }
        SearchAutoComplete searchAutoComplete = this.v;
        searchAutoComplete.setImeVisibility(false);
        searchAutoComplete.dismissDropDown();
    }

    public final void m(int i4) {
        Editable text = this.v.getText();
        Cursor cursor = this.f2751U.f478c;
        if (cursor == null) {
            return;
        }
        if (!cursor.moveToPosition(i4)) {
            setQuery(text);
            return;
        }
        String strC = this.f2751U.c(cursor);
        if (strC != null) {
            setQuery(strC);
        } else {
            setQuery(text);
        }
    }

    public final void n(CharSequence charSequence) {
        setQuery(charSequence);
    }

    public final void o() {
        SearchAutoComplete searchAutoComplete = this.v;
        Editable text = searchAutoComplete.getText();
        if (text == null || TextUtils.getTrimmedLength(text) <= 0) {
            return;
        }
        if (this.h0 != null) {
            getContext().startActivity(h(null, "android.intent.action.SEARCH", null, text.toString()));
        }
        searchAutoComplete.setImeVisibility(false);
        searchAutoComplete.dismissDropDown();
    }

    @Override // android.view.ViewGroup, android.view.View
    public final void onDetachedFromWindow() {
        removeCallbacks(this.f2762j0);
        post(this.f2763k0);
        super.onDetachedFromWindow();
    }

    @Override // k.AbstractC0478F, android.view.ViewGroup, android.view.View
    public final void onLayout(boolean z4, int i4, int i5, int i6, int i7) {
        super.onLayout(z4, i4, i5, i6, i7);
        if (z4) {
            int[] iArr = this.f2739H;
            SearchAutoComplete searchAutoComplete = this.v;
            searchAutoComplete.getLocationInWindow(iArr);
            int[] iArr2 = this.f2740I;
            getLocationInWindow(iArr2);
            int i8 = iArr[1] - iArr2[1];
            int i9 = iArr[0] - iArr2[0];
            int width = searchAutoComplete.getWidth() + i9;
            int height = searchAutoComplete.getHeight() + i8;
            Rect rect = this.f2737F;
            rect.set(i9, i8, width, height);
            int i10 = rect.left;
            int i11 = rect.right;
            int i12 = i7 - i5;
            Rect rect2 = this.f2738G;
            rect2.set(i10, 0, i11, i12);
            d0 d0Var = this.f2736E;
            if (d0Var == null) {
                d0 d0Var2 = new d0(rect2, rect, searchAutoComplete);
                this.f2736E = d0Var2;
                setTouchDelegate(d0Var2);
            } else {
                d0Var.f5343b.set(rect2);
                Rect rect3 = d0Var.f5345d;
                rect3.set(rect2);
                int i13 = -d0Var.e;
                rect3.inset(i13, i13);
                d0Var.f5344c.set(rect);
            }
        }
    }

    @Override // k.AbstractC0478F, android.view.View
    public final void onMeasure(int i4, int i5) {
        int i6;
        if (this.f2750T) {
            super.onMeasure(i4, i5);
            return;
        }
        int mode = View.MeasureSpec.getMode(i4);
        int size = View.MeasureSpec.getSize(i4);
        if (mode == Integer.MIN_VALUE) {
            int i7 = this.f2756c0;
            size = i7 > 0 ? Math.min(i7, size) : Math.min(getPreferredWidth(), size);
        } else if (mode == 0) {
            size = this.f2756c0;
            if (size <= 0) {
                size = getPreferredWidth();
            }
        } else if (mode == 1073741824 && (i6 = this.f2756c0) > 0) {
            size = Math.min(i6, size);
        }
        int mode2 = View.MeasureSpec.getMode(i5);
        int size2 = View.MeasureSpec.getSize(i5);
        if (mode2 == Integer.MIN_VALUE) {
            size2 = Math.min(getPreferredHeight(), size2);
        } else if (mode2 == 0) {
            size2 = getPreferredHeight();
        }
        super.onMeasure(View.MeasureSpec.makeMeasureSpec(size, 1073741824), View.MeasureSpec.makeMeasureSpec(size2, 1073741824));
    }

    @Override // android.view.View
    public final void onRestoreInstanceState(Parcelable parcelable) {
        if (!(parcelable instanceof c0)) {
            super.onRestoreInstanceState(parcelable);
            return;
        }
        c0 c0Var = (c0) parcelable;
        super.onRestoreInstanceState(c0Var.f507a);
        u(c0Var.f5341c);
        requestLayout();
    }

    @Override // android.view.View
    public final Parcelable onSaveInstanceState() {
        c0 c0Var = new c0(super.onSaveInstanceState());
        c0Var.f5341c = this.f2750T;
        return c0Var;
    }

    @Override // android.view.View
    public final void onWindowFocusChanged(boolean z4) {
        super.onWindowFocusChanged(z4);
        post(this.f2762j0);
    }

    public final void p() {
        boolean zIsEmpty = TextUtils.isEmpty(this.v.getText());
        int i4 = (!zIsEmpty || (this.f2749S && !this.f2759f0)) ? 0 : 8;
        ImageView imageView = this.f2733B;
        imageView.setVisibility(i4);
        Drawable drawable = imageView.getDrawable();
        if (drawable != null) {
            drawable.setState(!zIsEmpty ? ViewGroup.ENABLED_STATE_SET : ViewGroup.EMPTY_STATE_SET);
        }
    }

    public final void q() {
        int[] iArr = this.v.hasFocus() ? ViewGroup.FOCUSED_STATE_SET : ViewGroup.EMPTY_STATE_SET;
        Drawable background = this.f2766x.getBackground();
        if (background != null) {
            background.setState(iArr);
        }
        Drawable background2 = this.f2767y.getBackground();
        if (background2 != null) {
            background2.setState(iArr);
        }
        invalidate();
    }

    /* JADX WARN: Type inference fix 'apply assigned field type' failed
    java.lang.UnsupportedOperationException: ArgType.getObject(), call class: class jadx.core.dex.instructions.args.ArgType$UnknownArg
    	at jadx.core.dex.instructions.args.ArgType.getObject(ArgType.java:593)
    	at jadx.core.dex.attributes.nodes.ClassTypeVarsAttr.getTypeVarsMapFor(ClassTypeVarsAttr.java:35)
    	at jadx.core.dex.nodes.utils.TypeUtils.replaceClassGenerics(TypeUtils.java:177)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.insertExplicitUseCast(FixTypesVisitor.java:397)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.tryFieldTypeWithNewCasts(FixTypesVisitor.java:359)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.applyFieldType(FixTypesVisitor.java:309)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.visit(FixTypesVisitor.java:94)
     */
    public final void r() {
        CharSequence queryHint = getQueryHint();
        CharSequence charSequence = queryHint;
        if (queryHint == null) {
            charSequence = "";
        }
        boolean z4 = this.f2749S;
        SearchAutoComplete searchAutoComplete = this.v;
        CharSequence charSequence2 = charSequence;
        if (z4) {
            Drawable drawable = this.f2741K;
            charSequence2 = charSequence;
            if (drawable != null) {
                int textSize = (int) (((double) searchAutoComplete.getTextSize()) * 1.25d);
                drawable.setBounds(0, 0, textSize, textSize);
                SpannableStringBuilder spannableStringBuilder = new SpannableStringBuilder("   ");
                spannableStringBuilder.setSpan(new ImageSpan(drawable), 1, 2, 33);
                spannableStringBuilder.append(charSequence);
                charSequence2 = spannableStringBuilder;
            }
        }
        searchAutoComplete.setHint(charSequence2);
    }

    @Override // android.view.ViewGroup, android.view.View
    public final boolean requestFocus(int i4, Rect rect) {
        if (this.f2755b0 || !isFocusable()) {
            return false;
        }
        if (this.f2750T) {
            return super.requestFocus(i4, rect);
        }
        boolean zRequestFocus = this.v.requestFocus(i4, rect);
        if (zRequestFocus) {
            u(false);
        }
        return zRequestFocus;
    }

    public final void s() {
        this.f2767y.setVisibility(((this.f2752V || this.f2757d0) && !this.f2750T && (this.f2732A.getVisibility() == 0 || this.f2734C.getVisibility() == 0)) ? 0 : 8);
    }

    public void setAppSearchData(Bundle bundle) {
        this.f2761i0 = bundle;
    }

    public void setIconified(boolean z4) {
        if (z4) {
            k();
            return;
        }
        u(false);
        SearchAutoComplete searchAutoComplete = this.v;
        searchAutoComplete.requestFocus();
        searchAutoComplete.setImeVisibility(true);
        View.OnClickListener onClickListener = this.f2748R;
        if (onClickListener != null) {
            onClickListener.onClick(this);
        }
    }

    public void setIconifiedByDefault(boolean z4) {
        if (this.f2749S == z4) {
            return;
        }
        this.f2749S = z4;
        u(z4);
        r();
    }

    public void setImeOptions(int i4) {
        this.v.setImeOptions(i4);
    }

    public void setInputType(int i4) {
        this.v.setInputType(i4);
    }

    public void setMaxWidth(int i4) {
        this.f2756c0 = i4;
        requestLayout();
    }

    public void setOnQueryTextFocusChangeListener(View.OnFocusChangeListener onFocusChangeListener) {
        this.f2747Q = onFocusChangeListener;
    }

    public void setOnSearchClickListener(View.OnClickListener onClickListener) {
        this.f2748R = onClickListener;
    }

    public void setQueryHint(CharSequence charSequence) {
        this.f2753W = charSequence;
        r();
    }

    public void setQueryRefinementEnabled(boolean z4) {
        this.f2754a0 = z4;
        G.b bVar = this.f2751U;
        if (bVar instanceof f0) {
            ((f0) bVar).f5365w = z4 ? 2 : 1;
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:34:0x0098  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public void setSearchableInfo(android.app.SearchableInfo r7) {
        /*
            r6 = this;
            r6.h0 = r7
            r0 = 0
            r1 = 1
            androidx.appcompat.widget.SearchView$SearchAutoComplete r2 = r6.v
            if (r7 == 0) goto L65
            int r7 = r7.getSuggestThreshold()
            r2.setThreshold(r7)
            android.app.SearchableInfo r7 = r6.h0
            int r7 = r7.getImeOptions()
            r2.setImeOptions(r7)
            android.app.SearchableInfo r7 = r6.h0
            int r7 = r7.getInputType()
            r3 = r7 & 15
            if (r3 != r1) goto L31
            r3 = -65537(0xfffffffffffeffff, float:NaN)
            r7 = r7 & r3
            android.app.SearchableInfo r3 = r6.h0
            java.lang.String r3 = r3.getSuggestAuthority()
            if (r3 == 0) goto L31
            r3 = 589824(0x90000, float:8.2652E-40)
            r7 = r7 | r3
        L31:
            r2.setInputType(r7)
            G.b r7 = r6.f2751U
            if (r7 == 0) goto L3b
            r7.b(r0)
        L3b:
            android.app.SearchableInfo r7 = r6.h0
            java.lang.String r7 = r7.getSuggestAuthority()
            if (r7 == 0) goto L62
            k.f0 r7 = new k.f0
            android.content.Context r3 = r6.getContext()
            android.app.SearchableInfo r4 = r6.h0
            java.util.WeakHashMap r5 = r6.f2764l0
            r7.<init>(r3, r6, r4, r5)
            r6.f2751U = r7
            r2.setAdapter(r7)
            G.b r7 = r6.f2751U
            k.f0 r7 = (k.f0) r7
            boolean r3 = r6.f2754a0
            if (r3 == 0) goto L5f
            r3 = 2
            goto L60
        L5f:
            r3 = r1
        L60:
            r7.f5365w = r3
        L62:
            r6.r()
        L65:
            android.app.SearchableInfo r7 = r6.h0
            r3 = 0
            if (r7 == 0) goto L98
            boolean r7 = r7.getVoiceSearchEnabled()
            if (r7 == 0) goto L98
            android.app.SearchableInfo r7 = r6.h0
            boolean r7 = r7.getVoiceSearchLaunchWebSearch()
            if (r7 == 0) goto L7b
            android.content.Intent r0 = r6.f2744N
            goto L85
        L7b:
            android.app.SearchableInfo r7 = r6.h0
            boolean r7 = r7.getVoiceSearchLaunchRecognizer()
            if (r7 == 0) goto L85
            android.content.Intent r0 = r6.f2745O
        L85:
            if (r0 == 0) goto L98
            android.content.Context r7 = r6.getContext()
            android.content.pm.PackageManager r7 = r7.getPackageManager()
            r4 = 65536(0x10000, float:9.1835E-41)
            android.content.pm.ResolveInfo r7 = r7.resolveActivity(r0, r4)
            if (r7 == 0) goto L98
            goto L99
        L98:
            r1 = r3
        L99:
            r6.f2757d0 = r1
            if (r1 == 0) goto La2
            java.lang.String r7 = "nm"
            r2.setPrivateImeOptions(r7)
        La2:
            boolean r7 = r6.f2750T
            r6.u(r7)
            return
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.appcompat.widget.SearchView.setSearchableInfo(android.app.SearchableInfo):void");
    }

    public void setSubmitButtonEnabled(boolean z4) {
        this.f2752V = z4;
        u(this.f2750T);
    }

    public void setSuggestionsAdapter(G.b bVar) {
        this.f2751U = bVar;
        this.v.setAdapter(bVar);
    }

    public final void t(boolean z4) {
        boolean z5 = this.f2752V;
        this.f2732A.setVisibility((!z5 || !(z5 || this.f2757d0) || this.f2750T || !hasFocus() || (!z4 && this.f2757d0)) ? 8 : 0);
    }

    public final void u(boolean z4) {
        this.f2750T = z4;
        int i4 = 8;
        int i5 = z4 ? 0 : 8;
        boolean zIsEmpty = TextUtils.isEmpty(this.v.getText());
        this.f2768z.setVisibility(i5);
        t(!zIsEmpty);
        this.f2765w.setVisibility(z4 ? 8 : 0);
        ImageView imageView = this.J;
        imageView.setVisibility((imageView.getDrawable() == null || this.f2749S) ? 8 : 0);
        p();
        if (this.f2757d0 && !this.f2750T && zIsEmpty) {
            this.f2732A.setVisibility(8);
            i4 = 0;
        }
        this.f2734C.setVisibility(i4);
        s();
    }

    public SearchView(Context context, AttributeSet attributeSet) {
        this(context, attributeSet, R.attr.searchViewStyle);
    }

    public SearchView(Context context, AttributeSet attributeSet, int i4) {
        super(context, attributeSet, i4);
        this.f2737F = new Rect();
        this.f2738G = new Rect();
        this.f2739H = new int[2];
        this.f2740I = new int[2];
        this.f2762j0 = new U(this, 0);
        this.f2763k0 = new U(this, 1);
        this.f2764l0 = new WeakHashMap();
        a aVar = new a(this);
        b bVar = new b(this);
        X x4 = new X(this);
        Y y4 = new Y(this);
        C0479G c0479g = new C0479G(this, 1);
        T t4 = new T(this);
        TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(attributeSet, AbstractC0398a.f4259q, i4, 0);
        C0747k c0747k = new C0747k(context, typedArrayObtainStyledAttributes);
        LayoutInflater.from(context).inflate(typedArrayObtainStyledAttributes.getResourceId(9, R.layout.abc_search_view), (ViewGroup) this, true);
        SearchAutoComplete searchAutoComplete = (SearchAutoComplete) findViewById(R.id.search_src_text);
        this.v = searchAutoComplete;
        searchAutoComplete.setSearchView(this);
        this.f2765w = findViewById(R.id.search_edit_frame);
        View viewFindViewById = findViewById(R.id.search_plate);
        this.f2766x = viewFindViewById;
        View viewFindViewById2 = findViewById(R.id.submit_area);
        this.f2767y = viewFindViewById2;
        ImageView imageView = (ImageView) findViewById(R.id.search_button);
        this.f2768z = imageView;
        ImageView imageView2 = (ImageView) findViewById(R.id.search_go_btn);
        this.f2732A = imageView2;
        ImageView imageView3 = (ImageView) findViewById(R.id.search_close_btn);
        this.f2733B = imageView3;
        ImageView imageView4 = (ImageView) findViewById(R.id.search_voice_btn);
        this.f2734C = imageView4;
        ImageView imageView5 = (ImageView) findViewById(R.id.search_mag_icon);
        this.J = imageView5;
        Drawable drawableF = c0747k.F(10);
        Field field = C.f4a;
        viewFindViewById.setBackground(drawableF);
        viewFindViewById2.setBackground(c0747k.F(14));
        imageView.setImageDrawable(c0747k.F(13));
        imageView2.setImageDrawable(c0747k.F(7));
        imageView3.setImageDrawable(c0747k.F(4));
        imageView4.setImageDrawable(c0747k.F(16));
        imageView5.setImageDrawable(c0747k.F(13));
        this.f2741K = c0747k.F(12);
        AbstractC0367g.K(imageView, getResources().getString(R.string.abc_searchview_description_search));
        this.f2742L = typedArrayObtainStyledAttributes.getResourceId(15, R.layout.abc_search_dropdown_item_icons_2line);
        this.f2743M = typedArrayObtainStyledAttributes.getResourceId(5, 0);
        imageView.setOnClickListener(aVar);
        imageView3.setOnClickListener(aVar);
        imageView2.setOnClickListener(aVar);
        imageView4.setOnClickListener(aVar);
        searchAutoComplete.setOnClickListener(aVar);
        searchAutoComplete.addTextChangedListener(t4);
        searchAutoComplete.setOnEditorActionListener(x4);
        searchAutoComplete.setOnItemClickListener(y4);
        searchAutoComplete.setOnItemSelectedListener(c0479g);
        searchAutoComplete.setOnKeyListener(bVar);
        searchAutoComplete.setOnFocusChangeListener(new V(this));
        setIconifiedByDefault(typedArrayObtainStyledAttributes.getBoolean(8, true));
        int dimensionPixelSize = typedArrayObtainStyledAttributes.getDimensionPixelSize(1, -1);
        if (dimensionPixelSize != -1) {
            setMaxWidth(dimensionPixelSize);
        }
        this.f2746P = typedArrayObtainStyledAttributes.getText(6);
        this.f2753W = typedArrayObtainStyledAttributes.getText(11);
        int i5 = typedArrayObtainStyledAttributes.getInt(3, -1);
        if (i5 != -1) {
            setImeOptions(i5);
        }
        int i6 = typedArrayObtainStyledAttributes.getInt(2, -1);
        if (i6 != -1) {
            setInputType(i6);
        }
        setFocusable(typedArrayObtainStyledAttributes.getBoolean(0, true));
        c0747k.T();
        Intent intent = new Intent("android.speech.action.WEB_SEARCH");
        this.f2744N = intent;
        intent.addFlags(268435456);
        intent.putExtra("android.speech.extra.LANGUAGE_MODEL", "web_search");
        Intent intent2 = new Intent("android.speech.action.RECOGNIZE_SPEECH");
        this.f2745O = intent2;
        intent2.addFlags(268435456);
        View viewFindViewById3 = findViewById(searchAutoComplete.getDropDownAnchor());
        this.f2735D = viewFindViewById3;
        if (viewFindViewById3 != null) {
            viewFindViewById3.addOnLayoutChangeListener(new W(this));
        }
        u(this.f2749S);
        r();
    }

    public void setOnCloseListener(Z z4) {
    }

    public void setOnQueryTextListener(a0 a0Var) {
    }

    public void setOnSuggestionListener(b0 b0Var) {
    }
}
