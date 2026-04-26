package io.flutter.plugin.platform;

import android.view.View;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class k implements View.OnFocusChangeListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f4636a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ int f4637b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ j f4638c;

    public /* synthetic */ k(j jVar, int i4, int i5) {
        this.f4636a = i5;
        this.f4638c = jVar;
        this.f4637b = i4;
    }

    @Override // android.view.View.OnFocusChangeListener
    public final void onFocusChange(View view, boolean z4) {
        switch (this.f4636a) {
            case 0:
                q qVar = (q) this.f4638c;
                int i4 = this.f4637b;
                if (!z4) {
                    io.flutter.plugin.editing.i iVar = qVar.f4671m;
                    if (iVar != null) {
                        iVar.b(i4);
                    }
                    break;
                } else {
                    C0747k c0747k = (C0747k) qVar.f4672n.f260b;
                    if (c0747k != null) {
                        c0747k.O("viewFocused", Integer.valueOf(i4), null);
                        break;
                    }
                }
                break;
            default:
                p pVar = (p) this.f4638c;
                int i5 = this.f4637b;
                if (!z4) {
                    io.flutter.plugin.editing.i iVar2 = pVar.f4652f;
                    if (iVar2 != null) {
                        iVar2.b(i5);
                    }
                    break;
                } else {
                    C0747k c0747k2 = (C0747k) pVar.f4653m.f260b;
                    if (c0747k2 != null) {
                        c0747k2.O("viewFocused", Integer.valueOf(i5), null);
                        break;
                    }
                }
                break;
        }
    }
}
