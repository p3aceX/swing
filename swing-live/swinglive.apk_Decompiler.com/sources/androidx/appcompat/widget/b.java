package androidx.appcompat.widget;

import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.View;
import androidx.appcompat.widget.SearchView;
import java.lang.reflect.Method;

/* JADX INFO: loaded from: classes.dex */
public final class b implements View.OnKeyListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ SearchView f2848a;

    public b(SearchView searchView) {
        this.f2848a = searchView;
    }

    @Override // android.view.View.OnKeyListener
    public final boolean onKey(View view, int i4, KeyEvent keyEvent) {
        SearchView searchView = this.f2848a;
        if (searchView.h0 != null) {
            SearchView.SearchAutoComplete searchAutoComplete = searchView.v;
            if (!searchAutoComplete.isPopupShowing() || searchAutoComplete.getListSelection() == -1) {
                if (TextUtils.getTrimmedLength(searchAutoComplete.getText()) != 0 && keyEvent.hasNoModifiers() && keyEvent.getAction() == 1 && i4 == 66) {
                    view.cancelLongPress();
                    searchView.getContext().startActivity(searchView.h(null, "android.intent.action.SEARCH", null, searchAutoComplete.getText().toString()));
                    return true;
                }
            } else if (searchView.h0 != null && searchView.f2751U != null && keyEvent.getAction() == 0 && keyEvent.hasNoModifiers()) {
                if (i4 == 66 || i4 == 84 || i4 == 61) {
                    searchView.l(searchAutoComplete.getListSelection());
                    return true;
                }
                if (i4 == 21 || i4 == 22) {
                    searchAutoComplete.setSelection(i4 == 21 ? 0 : searchAutoComplete.length());
                    searchAutoComplete.setListSelection(0);
                    searchAutoComplete.clearListSelection();
                    Method method = SearchView.f2731m0.f89c;
                    if (method != null) {
                        try {
                            method.invoke(searchAutoComplete, Boolean.TRUE);
                        } catch (Exception unused) {
                        }
                    }
                    return true;
                }
                if (i4 == 19) {
                    searchAutoComplete.getListSelection();
                    return false;
                }
            }
        }
        return false;
    }
}
