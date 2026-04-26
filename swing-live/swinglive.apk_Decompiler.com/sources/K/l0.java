package k;

import android.content.Context;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import androidx.appcompat.widget.SearchView;
import androidx.appcompat.widget.Toolbar;
import i.InterfaceC0416a;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class l0 implements j.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public j.j f5405a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public j.k f5406b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ Toolbar f5407c;

    public l0(Toolbar toolbar) {
        this.f5407c = toolbar;
    }

    @Override // j.p
    public final void c(Context context, j.j jVar) {
        j.k kVar;
        j.j jVar2 = this.f5405a;
        if (jVar2 != null && (kVar = this.f5406b) != null) {
            jVar2.d(kVar);
        }
        this.f5405a = jVar;
    }

    @Override // j.p
    public final boolean d() {
        return false;
    }

    @Override // j.p
    public final boolean e(j.k kVar) {
        Toolbar toolbar = this.f5407c;
        toolbar.c();
        ViewParent parent = toolbar.f2831n.getParent();
        if (parent != toolbar) {
            if (parent instanceof ViewGroup) {
                ((ViewGroup) parent).removeView(toolbar.f2831n);
            }
            toolbar.addView(toolbar.f2831n);
        }
        View view = kVar.f5125z;
        if (view == null) {
            view = null;
        }
        toolbar.f2832o = view;
        this.f5406b = kVar;
        ViewParent parent2 = view.getParent();
        if (parent2 != toolbar) {
            if (parent2 instanceof ViewGroup) {
                ((ViewGroup) parent2).removeView(toolbar.f2832o);
            }
            m0 m0VarG = Toolbar.g();
            m0VarG.f5411a = (toolbar.f2837t & 112) | 8388611;
            m0VarG.f5412b = 2;
            toolbar.f2832o.setLayoutParams(m0VarG);
            toolbar.addView(toolbar.f2832o);
        }
        for (int childCount = toolbar.getChildCount() - 1; childCount >= 0; childCount--) {
            View childAt = toolbar.getChildAt(childCount);
            if (((m0) childAt.getLayoutParams()).f5412b != 2 && childAt != toolbar.f2825a) {
                toolbar.removeViewAt(childCount);
                toolbar.f2818K.add(childAt);
            }
        }
        toolbar.requestLayout();
        kVar.f5101B = true;
        kVar.f5114n.o(false);
        KeyEvent.Callback callback = toolbar.f2832o;
        if (callback instanceof InterfaceC0416a) {
            SearchView searchView = (SearchView) ((InterfaceC0416a) callback);
            if (!searchView.f2759f0) {
                searchView.f2759f0 = true;
                SearchView.SearchAutoComplete searchAutoComplete = searchView.v;
                int imeOptions = searchAutoComplete.getImeOptions();
                searchView.f2760g0 = imeOptions;
                searchAutoComplete.setImeOptions(imeOptions | 33554432);
                searchAutoComplete.setText("");
                searchView.setIconified(false);
            }
        }
        return true;
    }

    @Override // j.p
    public final void f() {
        if (this.f5406b != null) {
            j.j jVar = this.f5405a;
            if (jVar != null) {
                int size = jVar.f5085f.size();
                for (int i4 = 0; i4 < size; i4++) {
                    if (this.f5405a.getItem(i4) == this.f5406b) {
                        return;
                    }
                }
            }
            i(this.f5406b);
        }
    }

    @Override // j.p
    public final boolean i(j.k kVar) {
        Toolbar toolbar = this.f5407c;
        KeyEvent.Callback callback = toolbar.f2832o;
        if (callback instanceof InterfaceC0416a) {
            SearchView searchView = (SearchView) ((InterfaceC0416a) callback);
            SearchView.SearchAutoComplete searchAutoComplete = searchView.v;
            searchAutoComplete.setText("");
            searchAutoComplete.setSelection(searchAutoComplete.length());
            searchView.f2758e0 = "";
            searchView.clearFocus();
            searchView.u(true);
            searchAutoComplete.setImeOptions(searchView.f2760g0);
            searchView.f2759f0 = false;
        }
        toolbar.removeView(toolbar.f2832o);
        toolbar.removeView(toolbar.f2831n);
        toolbar.f2832o = null;
        ArrayList arrayList = toolbar.f2818K;
        for (int size = arrayList.size() - 1; size >= 0; size--) {
            toolbar.addView((View) arrayList.get(size));
        }
        arrayList.clear();
        this.f5406b = null;
        toolbar.requestLayout();
        kVar.f5101B = false;
        kVar.f5114n.o(false);
        return true;
    }

    @Override // j.p
    public final boolean k(j.t tVar) {
        return false;
    }

    @Override // j.p
    public final void a(j.j jVar, boolean z4) {
    }
}
