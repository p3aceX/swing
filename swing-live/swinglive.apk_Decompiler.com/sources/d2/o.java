package D2;

import android.database.ContentObserver;
import android.database.Cursor;
import android.net.Uri;
import android.os.Handler;
import android.provider.Settings;
import io.flutter.embedding.engine.FlutterJNI;
import k.f0;

/* JADX INFO: loaded from: classes.dex */
public final class o extends ContentObserver {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f223a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f224b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public /* synthetic */ o(Object obj, Handler handler, int i4) {
        super(handler);
        this.f223a = i4;
        this.f224b = obj;
    }

    @Override // android.database.ContentObserver
    public boolean deliverSelfNotifications() {
        switch (this.f223a) {
            case 0:
                return true;
            case 1:
                return true;
            default:
                return super.deliverSelfNotifications();
        }
    }

    @Override // android.database.ContentObserver
    public void onChange(boolean z4, Uri uri) {
        switch (this.f223a) {
            case 2:
                io.flutter.view.k kVar = (io.flutter.view.k) this.f224b;
                if (!kVar.f4807u) {
                    if (Settings.Global.getFloat(kVar.f4792f, "transition_animation_scale", 1.0f) == 0.0f) {
                        kVar.f4798l |= 4;
                    } else {
                        kVar.f4798l &= -5;
                    }
                    ((FlutterJNI) kVar.f4789b.f6832c).setAccessibilityFeatures(kVar.f4798l);
                    break;
                }
                break;
            default:
                super.onChange(z4, uri);
                break;
        }
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public o(f0 f0Var) {
        super(new Handler());
        this.f223a = 1;
        this.f224b = f0Var;
    }

    @Override // android.database.ContentObserver
    public final void onChange(boolean z4) {
        Cursor cursor;
        switch (this.f223a) {
            case 0:
                super.onChange(z4);
                r rVar = (r) this.f224b;
                if (rVar.f246p != null) {
                    rVar.d();
                    break;
                }
                break;
            case 1:
                f0 f0Var = (f0) this.f224b;
                if (f0Var.f477b && (cursor = f0Var.f478c) != null && !cursor.isClosed()) {
                    f0Var.f476a = f0Var.f478c.requery();
                    break;
                }
                break;
            default:
                onChange(z4, null);
                break;
        }
    }
}
