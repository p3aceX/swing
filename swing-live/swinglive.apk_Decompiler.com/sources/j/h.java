package j;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import androidx.appcompat.view.menu.ListMenuItemView;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class h extends BaseAdapter {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final j f5075a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f5076b = -1;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f5077c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final boolean f5078d;
    public final LayoutInflater e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int f5079f;

    public h(j jVar, LayoutInflater layoutInflater, boolean z4, int i4) {
        this.f5078d = z4;
        this.e = layoutInflater;
        this.f5075a = jVar;
        this.f5079f = i4;
        a();
    }

    public final void a() {
        j jVar = this.f5075a;
        k kVar = jVar.f5098s;
        if (kVar != null) {
            jVar.i();
            ArrayList arrayList = jVar.f5089j;
            int size = arrayList.size();
            for (int i4 = 0; i4 < size; i4++) {
                if (((k) arrayList.get(i4)) == kVar) {
                    this.f5076b = i4;
                    return;
                }
            }
        }
        this.f5076b = -1;
    }

    @Override // android.widget.Adapter
    /* JADX INFO: renamed from: b, reason: merged with bridge method [inline-methods] */
    public final k getItem(int i4) {
        ArrayList arrayListK;
        j jVar = this.f5075a;
        if (this.f5078d) {
            jVar.i();
            arrayListK = jVar.f5089j;
        } else {
            arrayListK = jVar.k();
        }
        int i5 = this.f5076b;
        if (i5 >= 0 && i4 >= i5) {
            i4++;
        }
        return (k) arrayListK.get(i4);
    }

    @Override // android.widget.Adapter
    public final int getCount() {
        ArrayList arrayListK;
        j jVar = this.f5075a;
        if (this.f5078d) {
            jVar.i();
            arrayListK = jVar.f5089j;
        } else {
            arrayListK = jVar.k();
        }
        return this.f5076b < 0 ? arrayListK.size() : arrayListK.size() - 1;
    }

    @Override // android.widget.Adapter
    public final long getItemId(int i4) {
        return i4;
    }

    @Override // android.widget.Adapter
    public final View getView(int i4, View view, ViewGroup viewGroup) {
        boolean z4 = false;
        if (view == null) {
            view = this.e.inflate(this.f5079f, viewGroup, false);
        }
        int i5 = getItem(i4).f5103b;
        int i6 = i4 - 1;
        int i7 = i6 >= 0 ? getItem(i6).f5103b : i5;
        ListMenuItemView listMenuItemView = (ListMenuItemView) view;
        if (this.f5075a.l() && i5 != i7) {
            z4 = true;
        }
        listMenuItemView.setGroupDividerEnabled(z4);
        q qVar = (q) view;
        if (this.f5077c) {
            listMenuItemView.setForceShowIcon(true);
        }
        qVar.c(getItem(i4));
        return view;
    }

    @Override // android.widget.BaseAdapter
    public final void notifyDataSetChanged() {
        a();
        super.notifyDataSetChanged();
    }
}
