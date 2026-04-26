package C0;

import android.util.Log;
import java.util.Locale;

/* JADX INFO: loaded from: classes.dex */
public final class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f120a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f121b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f122c;

    public a(String str, String... strArr) {
        String string;
        if (strArr.length == 0) {
            string = "";
        } else {
            StringBuilder sb = new StringBuilder();
            sb.append('[');
            for (String str2 : strArr) {
                if (sb.length() > 1) {
                    sb.append(",");
                }
                sb.append(str2);
            }
            sb.append("] ");
            string = sb.toString();
        }
        this.f121b = string;
        this.f120a = str;
        int length = str.length();
        Object[] objArr = {str, 23};
        if (length > 23) {
            throw new IllegalArgumentException(String.format("tag \"%s\" is longer than the %d character maximum", objArr));
        }
        int i4 = 2;
        while (i4 <= 7 && !Log.isLoggable(this.f120a, i4)) {
            i4++;
        }
        this.f122c = i4;
    }

    public final void a(String str, Object... objArr) {
        if (this.f122c <= 3) {
            Log.d(this.f120a, d(str, objArr));
        }
    }

    public final void b(String str, Exception exc, Object... objArr) {
        Log.e(this.f120a, d(str, objArr), exc);
    }

    public final void c(String str, Object... objArr) {
        Log.e(this.f120a, d(str, objArr));
    }

    public final String d(String str, Object... objArr) {
        if (objArr.length > 0) {
            str = String.format(Locale.US, str, objArr);
        }
        return this.f121b.concat(str);
    }

    public final void e(String str, Object... objArr) {
        if (this.f122c <= 2) {
            Log.v(this.f120a, d(str, objArr));
        }
    }

    public final void f(String str, Object... objArr) {
        Log.w(this.f120a, d(str, objArr));
    }
}
