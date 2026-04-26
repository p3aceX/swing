package P3;

import java.io.Serializable;
import java.util.regex.Pattern;

/* JADX INFO: loaded from: classes.dex */
public final class e implements Serializable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Pattern f1505a;

    public e(String str) {
        J3.i.e(str, "pattern");
        Pattern patternCompile = Pattern.compile(str);
        J3.i.d(patternCompile, "compile(...)");
        this.f1505a = patternCompile;
    }

    public final String toString() {
        String string = this.f1505a.toString();
        J3.i.d(string, "toString(...)");
        return string;
    }
}
