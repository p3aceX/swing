package k;

import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import androidx.appcompat.widget.SearchView;

/* JADX INFO: loaded from: classes.dex */
public final class T implements TextWatcher {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ SearchView f5330a;

    public T(SearchView searchView) {
        this.f5330a = searchView;
    }

    @Override // android.text.TextWatcher
    public final void onTextChanged(CharSequence charSequence, int i4, int i5, int i6) {
        SearchView searchView = this.f5330a;
        Editable text = searchView.v.getText();
        searchView.f2758e0 = text;
        boolean zIsEmpty = TextUtils.isEmpty(text);
        searchView.t(!zIsEmpty);
        int i7 = 8;
        if (searchView.f2757d0 && !searchView.f2750T && zIsEmpty) {
            searchView.f2732A.setVisibility(8);
            i7 = 0;
        }
        searchView.f2734C.setVisibility(i7);
        searchView.p();
        searchView.s();
        charSequence.toString();
    }

    @Override // android.text.TextWatcher
    public final void afterTextChanged(Editable editable) {
    }

    @Override // android.text.TextWatcher
    public final void beforeTextChanged(CharSequence charSequence, int i4, int i5, int i6) {
    }
}
