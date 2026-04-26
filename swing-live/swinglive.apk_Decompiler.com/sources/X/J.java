package X;

import android.view.View;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public final class J {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final ArrayList f2299a = new ArrayList();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2300b = Integer.MIN_VALUE;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f2301c = Integer.MIN_VALUE;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f2302d;
    public final /* synthetic */ StaggeredGridLayoutManager e;

    public J(StaggeredGridLayoutManager staggeredGridLayoutManager, int i4) {
        this.e = staggeredGridLayoutManager;
        this.f2302d = i4;
    }

    public final int a(int i4) {
        int i5 = this.f2301c;
        if (i5 != Integer.MIN_VALUE) {
            return i5;
        }
        if (this.f2299a.size() == 0) {
            return i4;
        }
        View view = (View) this.f2299a.get(r3.size() - 1);
        G g4 = (G) view.getLayoutParams();
        this.f2301c = this.e.f3187j.c(view);
        g4.getClass();
        return this.f2301c;
    }
}
