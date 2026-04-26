package Q;

import X.C0183n;
import X.t;
import android.view.View;
import com.google.crypto.tink.shaded.protobuf.AbstractC0296a;
import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import java.io.ByteArrayOutputStream;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public abstract class b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Object f1509a;

    public b(int i4) {
        switch (i4) {
            case 3:
                this.f1509a = new ByteArrayOutputStream();
                break;
            default:
                this.f1509a = new LinkedHashMap();
                break;
        }
    }

    public static b b(t tVar, int i4) {
        if (i4 == 0) {
            return new C0183n(tVar, 0);
        }
        if (i4 == 1) {
            return new C0183n(tVar, 1);
        }
        throw new IllegalArgumentException("invalid orientation");
    }

    public abstract AbstractC0296a a(AbstractC0296a abstractC0296a);

    public abstract int c(View view);

    public abstract int d(View view);

    public abstract int e();

    public abstract int f();

    public abstract int g();

    public Map h() {
        return Collections.EMPTY_MAP;
    }

    public abstract AbstractC0296a i(AbstractC0303h abstractC0303h);

    public abstract void j(AbstractC0296a abstractC0296a);

    public b(Class cls) {
        this.f1509a = cls;
    }
}
