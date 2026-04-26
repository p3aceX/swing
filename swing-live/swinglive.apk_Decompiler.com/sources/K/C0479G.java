package k;

import android.view.View;
import android.widget.AdapterView;
import androidx.appcompat.widget.SearchView;

/* JADX INFO: renamed from: k.G, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0479G implements AdapterView.OnItemSelectedListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5283a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f5284b;

    public /* synthetic */ C0479G(Object obj, int i4) {
        this.f5283a = i4;
        this.f5284b = obj;
    }

    @Override // android.widget.AdapterView.OnItemSelectedListener
    public final void onItemSelected(AdapterView adapterView, View view, int i4, long j4) {
        M m4;
        switch (this.f5283a) {
            case 0:
                if (i4 != -1 && (m4 = ((AbstractC0483K) this.f5284b).f5295c) != null) {
                    m4.setListSelectionHidden(false);
                    break;
                }
                break;
            default:
                ((SearchView) this.f5284b).m(i4);
                break;
        }
    }

    @Override // android.widget.AdapterView.OnItemSelectedListener
    public final void onNothingSelected(AdapterView adapterView) {
        int i4 = this.f5283a;
    }

    private final void a(AdapterView adapterView) {
    }

    private final void b(AdapterView adapterView) {
    }
}
