from flask import Flask
import functions

app = Flask(__name__)

@app.route("/calc/<funcname>")
def mycalc(funcname):
    print funcname
    func = getattr(functions, funcname, None)
    print func
    result = func([1,2,3])
    print result
    return str(result)

if __name__ == "__main__":
    app.run(host="0.0.0.0")
